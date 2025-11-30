"""
File Schemas
Pydantic models for file request/response validation
"""

from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from decimal import Decimal


class FileCreate(BaseModel):
    case_id: Optional[str] = None
    file_name: str
    original_file_name: str
    file_type: str  # 'xray', 'lab_result', 'photo', 'document', 'dicom'
    file_size: int
    mime_type: Optional[str] = None


class FileResponse(BaseModel):
    id: str
    case_id: Optional[str]
    uploaded_by: str
    file_name: str
    original_file_name: str
    file_type: str
    file_size: int
    s3_key: str
    s3_bucket: str
    s3_region: str
    mime_type: Optional[str]
    upload_status: str
    tus_upload_id: Optional[str]
    upload_progress: Decimal
    quality_score: Optional[Decimal]
    quality_issues: Optional[List[str]]
    is_analyzed: bool
    created_at: datetime
    completed_at: Optional[datetime]
    
    class Config:
        from_attributes = True


class TUSCreateResponse(BaseModel):
    """TUS Protocol: Response to POST request"""
    location: str
    upload_offset: int = 0
    upload_length: int


class TUSHeadResponse(BaseModel):
    """TUS Protocol: Response to HEAD request"""
    upload_offset: int
    upload_length: int
    upload_metadata: Optional[str] = None


class TUSPatchResponse(BaseModel):
    """TUS Protocol: Response to PATCH request"""
    upload_offset: int

