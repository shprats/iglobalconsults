"""
File Repository
Database operations for files
"""

from sqlalchemy.orm import Session
from sqlalchemy import select
from typing import Optional, List
from uuid import UUID
from app.models.file import File


class FileRepository:
    def __init__(self, db: Session):
        self.db = db
    
    def create(self, file_data: dict) -> File:
        """Create a new file record"""
        file = File(**file_data)
        self.db.add(file)
        self.db.commit()
        self.db.refresh(file)
        return file
    
    def get_by_id(self, file_id: str) -> Optional[File]:
        """Get file by ID"""
        try:
            uuid_id = UUID(file_id)
        except ValueError:
            return None
        stmt = select(File).where(File.id == uuid_id)
        result = self.db.execute(stmt)
        return result.scalar_one_or_none()
    
    def get_by_tus_id(self, tus_upload_id: str) -> Optional[File]:
        """Get file by TUS upload ID"""
        stmt = select(File).where(File.tus_upload_id == tus_upload_id)
        result = self.db.execute(stmt)
        return result.scalar_one_or_none()
    
    def get_by_case(self, case_id: str) -> List[File]:
        """Get all files for a case"""
        try:
            uuid_id = UUID(case_id)
        except ValueError:
            return []
        stmt = select(File).where(File.case_id == uuid_id)
        result = self.db.execute(stmt)
        return list(result.scalars().all())
    
    def update(self, file: File, update_data: dict) -> File:
        """Update file"""
        for key, value in update_data.items():
            if value is not None:
                setattr(file, key, value)
        self.db.commit()
        self.db.refresh(file)
        return file
    
    def update_upload_progress(self, file: File, bytes_uploaded: int, total_bytes: int) -> File:
        """Update upload progress"""
        if total_bytes > 0:
            progress = min(100.0, (bytes_uploaded / total_bytes) * 100.0)
            file.upload_progress = progress
            self.db.commit()
            self.db.refresh(file)
        return file
    
    def mark_completed(self, file: File) -> File:
        """Mark file upload as completed"""
        from datetime import datetime, timezone
        file.upload_status = 'completed'
        file.upload_progress = 100.0
        file.completed_at = datetime.now(timezone.utc)
        self.db.commit()
        self.db.refresh(file)
        return file
    
    def mark_failed(self, file: File, error_message: str) -> File:
        """Mark file upload as failed"""
        from datetime import datetime, timezone
        file.upload_status = 'failed'
        file.failed_at = datetime.now(timezone.utc)
        file.error_message = error_message
        self.db.commit()
        self.db.refresh(file)
        return file

