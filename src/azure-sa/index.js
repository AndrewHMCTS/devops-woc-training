const express = require('express');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const axios = require('axios');
require('dotenv').config();

const { BlobServiceClient, StorageSharedKeyCredential } = require('@azure/storage-blob');

const app = express();
const PORT = process.env.PORT || 3000;

// Backend API URL - uses Docker service name when in container
const BACKEND_URL = process.env.BACKEND_URL || 'http://backend:8000';

const upload = multer({ dest: 'uploads/' });

const sharedKeyCredential = new StorageSharedKeyCredential(
    process.env.AZURE_STORAGE_ACCOUNT_NAME,
    process.env.AZURE_STORAGE_ACCOUNT_KEY
);

const blobServiceClient = new BlobServiceClient(
    `https://${process.env.AZURE_STORAGE_ACCOUNT_NAME}.blob.core.windows.net`,
    sharedKeyCredential
);

const containerClient = blobServiceClient.getContainerClient(process.env.AZURE_CONTAINER_NAME);

app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());

app.post('/upload', upload.single('file'), async (req, res) => {
    const fileName = req.body.note;
    if (!fileName) {
        return res.status(400).send('File name is required.');
    }

    if (req.file) {
        try {
            const blobName = req.file.filename;
            const blockBlobClient = containerClient.getBlockBlobClient(blobName);

            // Upload to Azure
            await blockBlobClient.uploadFile(req.file.path);
            fs.unlinkSync(req.file.path); // remove the file locally after upload

            // Save metadata to PostgreSQL via backend
            await axios.post(`${BACKEND_URL}/upload`, {
                filename: fileName,
                uploaded_by: req.body.uploaded_by || 'unknown',
                blob_key: blobName  // Store the Azure blob key for reference
            }, {
                headers: { 'Content-Type': 'application/json' }
            });

            res.status(200).send('File uploaded successfully.');
        } catch (err) {
            console.error('Error uploading file:', err);
            res.status(500).send('Failed to upload file: ' + err.message);
        }
    } else {
        res.status(400).send('No file uploaded.');
    }
});

app.get('/files', async (req, res) => {
    try {
        // Fetch files from PostgreSQL via backend
        const response = await axios.get(`${BACKEND_URL}/files`);
        res.json(response.data);
    } catch (err) {
        console.error('Error fetching files:', err);
        res.status(500).json({ error: 'Failed to fetch files: ' + err.message });
    }
});

app.delete('/files/:key', async (req, res) => {
    const fileKey = req.params.key;

    try {
        // Delete from Azure Blob Storage
        const blockBlobClient = containerClient.getBlockBlobClient(fileKey);
        await blockBlobClient.delete();

        // Fetch all files from backend to find the one with matching blob_key
        const filesResponse = await axios.get(`${BACKEND_URL}/files?include_deleted=true`);
        const file = filesResponse.data.find(f => f.key === fileKey);
        
        if (file && file.id) {
            // Mark as deleted in PostgreSQL via backend
            await axios.post(`${BACKEND_URL}/delete/`, null, {
                params: { file_id: file.id }
            });
        }

        res.status(200).send('File deleted successfully.');
    } catch (err) {
        console.error('Error deleting file:', err.message);
        res.status(500).send('Failed to delete file: ' + err.message);
    }
});

// Health check endpoint for Azure App Service
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'healthy' });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on port ${PORT}`);
});




// const express = require('express');
// const multer = require('multer');
// const fs = require('fs');
// const path = require('path');
// require('dotenv').config();

// const { BlobServiceClient, StorageSharedKeyCredential } = require('@azure/storage-blob');

// const app = express();
// const PORT = process.env.PORT || 3000;

// const upload = multer({ dest: 'uploads/' });

// const sharedKeyCredential = new StorageSharedKeyCredential(
//     process.env.AZURE_STORAGE_ACCOUNT_NAME,
//     process.env.AZURE_STORAGE_ACCOUNT_KEY
// );

// const blobServiceClient = new BlobServiceClient(
//     `https://${process.env.AZURE_STORAGE_ACCOUNT_NAME}.blob.core.windows.net`,
//     sharedKeyCredential
// );

// const containerClient = blobServiceClient.getContainerClient(process.env.AZURE_CONTAINER_NAME);

// const filesDataPath = './filesData.json';

// const loadFilesData = () => {
//     if (fs.existsSync(filesDataPath)) {
//         const data = fs.readFileSync(filesDataPath);
//         return JSON.parse(data);
//     }
//     return [];
// };

// const saveFilesData = (files) => {
//     fs.writeFileSync(filesDataPath, JSON.stringify(files, null, 2));
// };

// let files = loadFilesData();

// app.use(express.static(path.join(__dirname, 'public')));
// app.use(express.json());

// app.post('/upload', upload.single('file'), async (req, res) => {
//     const fileName = req.body.note;
//     if (!fileName) {
//         return res.status(400).send('File name is required.');
//     }

//     if (req.file) {
//         try {
//             const blobName = req.file.filename;
//             const blockBlobClient = containerClient.getBlockBlobClient(blobName);

//             await blockBlobClient.uploadFile(req.file.path);
//             fs.unlinkSync(req.file.path); // remove the file locally after upload

//             files.push({ name: fileName, key: blobName });
//             saveFilesData(files);

//             res.status(200).send('File uploaded successfully.');
//         } catch (err) {
//             console.error('Error uploading file:', err);
//             res.status(500).send('Failed to upload file.');
//         }
//     } else {
//         res.status(400).send('No file uploaded.');
//     }
// });

// app.get('/files', (req, res) => {
//     res.json(files);
// });

// app.delete('/files/:key', async (req, res) => {
//     const fileKey = req.params.key;

//     try {
//         const blockBlobClient = containerClient.getBlockBlobClient(fileKey);
//         await blockBlobClient.delete();

//         files = files.filter(file => file.key !== fileKey);
//         saveFilesData(files);

//         res.status(200).send('File deleted successfully.');
//     } catch (err) {
//         console.error('Error deleting file:', err);
//         res.status(500).send('Failed to delete file.');
//     }
// });

// app.listen(PORT, () => {
//     console.log(`Server is running on port ${PORT}`);
// });
