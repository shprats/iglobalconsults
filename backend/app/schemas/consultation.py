"""
Consultation Schemas
Pydantic models for consultation request/response validation
"""

from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class ConsultationCreate(BaseModel):
    case_id: str
    scheduled_start: datetime
    scheduled_end: datetime
    patient_id: Optional[str] = None


class ConsultationUpdate(BaseModel):
    status: Optional[str] = None
    actual_start: Optional[datetime] = None
    actual_end: Optional[datetime] = None
    connection_quality: Optional[str] = None
    fallback_mode: Optional[str] = None
    volunteer_notes: Optional[str] = None
    diagnosis: Optional[str] = None
    treatment_plan: Optional[str] = None
    follow_up_required: Optional[bool] = None
    follow_up_notes: Optional[str] = None
    recording_consent_given: Optional[bool] = None


class ConsultationResponse(BaseModel):
    id: str
    case_id: str
    volunteer_id: str
    patient_id: Optional[str]
    requesting_doctor_id: str
    scheduled_start: datetime
    scheduled_end: datetime
    actual_start: Optional[datetime]
    actual_end: Optional[datetime]
    duration_minutes: Optional[int]
    status: str
    agora_channel_name: Optional[str]
    connection_quality: Optional[str]
    fallback_mode: Optional[str]
    volunteer_notes: Optional[str]
    diagnosis: Optional[str]
    treatment_plan: Optional[str]
    follow_up_required: bool
    follow_up_notes: Optional[str]
    recording_url: Optional[str]
    recording_consent_given: bool
    created_at: datetime
    updated_at: datetime
    cancelled_at: Optional[datetime]
    
    class Config:
        from_attributes = True


class ConsultationStartResponse(BaseModel):
    consultation_id: str
    agora_channel_name: str
    agora_app_id: str
    agora_token: str  # Generated Agora token for video call


class ConsultationListResponse(BaseModel):
    consultations: list[ConsultationResponse]
    total: int
    page: int
    page_size: int

