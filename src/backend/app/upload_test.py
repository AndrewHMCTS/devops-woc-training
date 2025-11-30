import requests
from datetime import datetime

# FastAPI endpoint URL
url = "http://127.0.0.1:8000/upload"

data = {
    "filename": "example_file_new.txt",
    "uploaded_by": "andrew",
    "uploaded_at": datetime.now().isoformat()
}

response = requests.post(url, json=data)
print(response.json())