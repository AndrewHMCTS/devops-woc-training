from azure.monitor.opentelemetry import configure_azure_monitor
import logging
import os

connection_string = os.getenv("APPLICATIONINSIGHTS_CONNECTION_STRING")
if connection_string:
    configure_azure_monitor(logger_name="filevault.backend",
                            connection_string=connection_string)
else:
    logging.warning("WARNING: No connection string found. Azure Monitor is disabled.")

logger = logging.getLogger("filevault.backend")

from fastapi import FastAPI, UploadFile, File, Depends
from sqlalchemy.orm import Session
from app.database import get_db, engine
from app import models
from app.crud import upload_file, delete_file
from typing import List, Optional
from pydantic import BaseModel, ConfigDict
from prometheus_fastapi_instrumentator import Instrumentator
from prometheus_client import Counter, Gauge
from datetime import datetime
import os

os.makedirs("./uploads", exist_ok=True)

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="File Vault Backend API")

instrumentator = Instrumentator(
    should_group_status_codes=True,  # group 2xx, 4xx, 5xx
    should_ignore_untemplated=True   # ignore routes without templates
)

# Expose metrics at /metrics endpoint
instrumentator.instrument(app).expose(app)

# customPrometheus metrics
files_uploaded = Counter("files_uploaded_total", "Total files uploaded")
files_deleted = Counter("files_deleted_total", "Total files deleted")
current_files = Gauge("current_file_count", "Current number of stored files")
upload_failures = Counter("upload_failures_total", "Failed upload attempts")
delete_failures = Counter("delete_failures_total", "Failed delete attempts")

# Pydantic schemas
class FileMetadataSchema(BaseModel):
    id: int
    filename: str
    uploaded_by: str
    uploaded_at: datetime
    deleted: bool
    deleted_at: Optional[datetime] = None
    
    model_config = ConfigDict(from_attributes=True)


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
    try:
        # Save metadata to database
        file_metadata = upload_file(
            db, 
            filename=request.filename, 
            uploaded_by=request.uploaded_by,
            blob_key=request.blob_key
        )
        # Increment Prometheus counters
        files_uploaded.inc()
        current_files.inc()
        
        return {
            "status": "success",
            "filename": file_metadata.filename,
            "id": file_metadata.id
        }
    except Exception as e:
        upload_failures.inc()
        raise e

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
    try:
        delete_file(db, file_id)
        files_deleted.inc()
        current_files.dec()
        return {"status": "deleted", "file_id": file_id}
    except Exception as e:
        delete_failures.inc()
        raise e

@app.get("/health")
def health():
    return {"status": "ok"}
