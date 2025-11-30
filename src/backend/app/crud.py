from datetime import datetime
from sqlalchemy.orm import Session
from app.models import FileMetadata 

def upload_file(session: Session, filename: str, uploaded_by: str, blob_key: str = None):
    new_file = FileMetadata(
        filename=filename,
        uploaded_by=uploaded_by,
        uploaded_at=datetime.now(),
        deleted=False,
        deleted_at=None,
        blob_key=blob_key
    )
    session.add(new_file)
    session.commit()
    session.refresh(new_file)
    return new_file

def delete_file(session: Session, file_id: int):
    file_record = session.query(FileMetadata).filter_by(id=file_id).first()
    if file_record:
        file_record.deleted = True
        file_record.deleted_at = datetime.now()
        session.commit()
        session.refresh(file_record)
        return file_record
    return None