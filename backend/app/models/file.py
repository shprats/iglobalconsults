"""
File Model
SQLAlchemy model for files table
"""

from sqlalchemy import Column, String, BigInteger, Numeric, Text, Boolean, DateTime, ARRAY
from sqlalchemy.dialects.postgresql import UUID, JSON
from sqlalchemy.sql import func
from app.core.database import Base
import uuid


class File(Base):
    __tablename__ = "files"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    case_id = Column(UUID(as_uuid=True), index=True)
    uploaded_by = Column(UUID(as_uuid=True), nullable=False, index=True)
    file_name = Column(String(255), nullable=False)
    original_file_name = Column(String(255), nullable=False)
    file_type = Column(String(50), nullable=False)  # 'xray', 'lab_result', 'photo', 'document', 'dicom'
    file_size = Column(BigInteger, nullable=False)
    s3_key = Column(String(500), nullable=False)
    s3_bucket = Column(String(100), nullable=False)
    s3_region = Column(String(50), nullable=False)
    mime_type = Column(String(100))
    upload_status = Column(String(50), default='pending', index=True)
    tus_upload_id = Column(String(255), unique=True, index=True)
    upload_progress = Column(Numeric(5, 2), default=0.00)  # 0.00 to 100.00
    quality_score = Column(Numeric(3, 2))  # 0.00 to 1.00
    quality_issues = Column(ARRAY(String))
    quality_analysis_at = Column(DateTime(timezone=True))
    is_analyzed = Column(Boolean, default=False)
    file_metadata = Column("metadata", JSON)  # DICOM metadata, image dimensions, etc.
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    started_at = Column(DateTime(timezone=True))
    completed_at = Column(DateTime(timezone=True))
    failed_at = Column(DateTime(timezone=True))
    error_message = Column(Text)

