from fastapi import FastAPI, UploadFile, File, Depends
from sqlalchemy.orm import Session
from app.database import get_db, engine
from app import models
from app.crud import upload_file, delete_file
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime
import os

os.makedirs("./uploads", exist_ok=True)

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="File Vault Backend API")

# Pydantic schemas
class FileMetadataSchema(BaseModel):
    id: int
    filename: str
    uploaded_by: str
    uploaded_at: datetime
    deleted: bool
    deleted_at: Optional[datetime] = None

    class Config:
        orm_mode = True


class UploadRequest(BaseModel):
    filename: str
    uploaded_by: str = "unknown"
    blob_key: Optional[str] = None


@app.get("/")
def root():
    return {"message": "FastAPI is running"}

@app.post("/upload")
async def upload_endpoint(
    request: UploadRequest,
    db: Session = Depends(get_db)
):
    # Save metadata to database
    file_metadata = upload_file(
        db, 
        filename=request.filename, 
        uploaded_by=request.uploaded_by,
        blob_key=request.blob_key
    )

    return {
        "status": "success",
        "filename": file_metadata.filename,
        "id": file_metadata.id
    }

@app.get("/files")
def list_files(include_deleted: bool = False, db: Session = Depends(get_db)):
    query = db.query(models.FileMetadata)
    if not include_deleted:
        query = query.filter(models.FileMetadata.deleted.is_(False))
    
    files = query.all()
    
    return [
        {
            "name": f.filename,     
            "key": f.blob_key,
            "id": f.id,             
            "uploaded_by": f.uploaded_by,
            "uploaded_at": f.uploaded_at,
            "deleted": f.deleted,
            "deleted_at": f.deleted_at
        } for f in files
    ]

@app.post("/delete/")
def delete_endpoint(file_id: int, db: Session = Depends(get_db)):
    delete_file(db, file_id)
    return {"status": "deleted", "file_id": file_id}