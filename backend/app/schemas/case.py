"""
Case Schemas
Pydantic models for case request/response validation
"""

from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from uuid import UUID


class CaseCreate(BaseModel):
    title: str
    chief_complaint: Optional[str] = None
    history: Optional[str] = None
    physical_exam_notes: Optional[str] = None
    urgency: str  # 'critical', 'priority', 'routine'
    patient_id: Optional[str] = None
    metadata: Optional[dict] = None


class CaseUpdate(BaseModel):
    title: Optional[str] = None
    chief_complaint: Optional[str] = None
    history: Optional[str] = None
    physical_exam_notes: Optional[str] = None
    urgency: Optional[str] = None
    status: Optional[str] = None
    patient_id: Optional[str] = None
    metadata: Optional[dict] = None


class CaseResponse(BaseModel):
    id: str
    requesting_doctor_id: str
    patient_id: Optional[str]
    title: str
    chief_complaint: Optional[str]
    history: Optional[str]
    physical_exam_notes: Optional[str]
    urgency: str
    status: str
    assigned_volunteer_id: Optional[str]
    priority_score: int
    created_at: datetime
    updated_at: datetime
    submitted_at: Optional[datetime]
    is_offline: bool
    
    class Config:
        from_attributes = True


class CaseListResponse(BaseModel):
    cases: list[CaseResponse]
    total: int
    page: int
    page_size: int

