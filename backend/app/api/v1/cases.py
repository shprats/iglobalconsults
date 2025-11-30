"""
Cases API Endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional
from uuid import UUID
from app.core.database import get_db
from app.api.v1.auth import get_current_user
from app.schemas.auth import UserResponse
from app.schemas.case import CaseCreate, CaseUpdate, CaseResponse, CaseListResponse
from app.repositories.case_repository import CaseRepository

router = APIRouter()


@router.post("/", response_model=CaseResponse, status_code=status.HTTP_201_CREATED)
async def create_case(
    case_data: CaseCreate,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new case"""
    # Only requesting doctors can create cases
    if current_user.role != 'requesting_doctor':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only requesting doctors can create cases"
        )
    
    # Validate urgency
    valid_urgencies = ['critical', 'priority', 'routine']
    if case_data.urgency not in valid_urgencies:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid urgency. Must be one of: {', '.join(valid_urgencies)}"
        )
    
    repo = CaseRepository(db)
    
    # Prepare case data
    case_dict = {
        "requesting_doctor_id": UUID(current_user.id),
        "title": case_data.title,
        "chief_complaint": case_data.chief_complaint,
        "history": case_data.history,
        "physical_exam_notes": case_data.physical_exam_notes,
        "urgency": case_data.urgency,
        "status": "draft",
        "priority_score": 0,
        "is_offline": False,
        "metadata": case_data.metadata
    }
    
    if case_data.patient_id:
        try:
            case_dict["patient_id"] = UUID(case_data.patient_id)
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid patient_id format"
            )
    
    case = repo.create(case_dict)
    
    return CaseResponse(
        id=str(case.id),
        requesting_doctor_id=str(case.requesting_doctor_id),
        patient_id=str(case.patient_id) if case.patient_id else None,
        title=case.title,
        chief_complaint=case.chief_complaint,
        history=case.history,
        physical_exam_notes=case.physical_exam_notes,
        urgency=case.urgency,
        status=case.status,
        assigned_volunteer_id=str(case.assigned_volunteer_id) if case.assigned_volunteer_id else None,
        priority_score=case.priority_score,
        created_at=case.created_at,
        updated_at=case.updated_at,
        submitted_at=case.submitted_at,
        is_offline=case.is_offline
    )


@router.get("/", response_model=CaseListResponse)
async def list_cases(
    status_filter: Optional[str] = Query(None, alias="status"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """List cases for current user"""
    repo = CaseRepository(db)
    
    # Only requesting doctors can list their own cases
    if current_user.role != 'requesting_doctor':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only requesting doctors can list cases"
        )
    
    cases, total = repo.list_by_doctor(
        doctor_id=current_user.id,
        status=status_filter,
        page=page,
        page_size=page_size
    )
    
    case_responses = [
        CaseResponse(
            id=str(case.id),
            requesting_doctor_id=str(case.requesting_doctor_id),
            patient_id=str(case.patient_id) if case.patient_id else None,
            title=case.title,
            chief_complaint=case.chief_complaint,
            history=case.history,
            physical_exam_notes=case.physical_exam_notes,
            urgency=case.urgency,
            status=case.status,
            assigned_volunteer_id=str(case.assigned_volunteer_id) if case.assigned_volunteer_id else None,
            priority_score=case.priority_score,
            created_at=case.created_at,
            updated_at=case.updated_at,
            submitted_at=case.submitted_at,
            is_offline=case.is_offline
        )
        for case in cases
    ]
    
    return CaseListResponse(
        cases=case_responses,
        total=total,
        page=page,
        page_size=page_size
    )


@router.get("/{case_id}", response_model=CaseResponse)
async def get_case(
    case_id: str,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get case by ID"""
    repo = CaseRepository(db)
    
    # Only requesting doctors can view their own cases
    if current_user.role != 'requesting_doctor':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only requesting doctors can view cases"
        )
    
    case = repo.get_by_id(case_id, doctor_id=current_user.id)
    
    if not case:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Case not found"
        )
    
    return CaseResponse(
        id=str(case.id),
        requesting_doctor_id=str(case.requesting_doctor_id),
        patient_id=str(case.patient_id) if case.patient_id else None,
        title=case.title,
        chief_complaint=case.chief_complaint,
        history=case.history,
        physical_exam_notes=case.physical_exam_notes,
        urgency=case.urgency,
        status=case.status,
        assigned_volunteer_id=str(case.assigned_volunteer_id) if case.assigned_volunteer_id else None,
        priority_score=case.priority_score,
        created_at=case.created_at,
        updated_at=case.updated_at,
        submitted_at=case.submitted_at,
        is_offline=case.is_offline
    )


@router.put("/{case_id}", response_model=CaseResponse)
async def update_case(
    case_id: str,
    case_update: CaseUpdate,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update a case"""
    repo = CaseRepository(db)
    
    if current_user.role != 'requesting_doctor':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only requesting doctors can update cases"
        )
    
    case = repo.get_by_id(case_id, doctor_id=current_user.id)
    if not case:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Case not found"
        )
    
    # Prepare update data
    update_dict = case_update.model_dump(exclude_unset=True)
    
    # Validate urgency if provided
    if 'urgency' in update_dict:
        valid_urgencies = ['critical', 'priority', 'routine']
        if update_dict['urgency'] not in valid_urgencies:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid urgency. Must be one of: {', '.join(valid_urgencies)}"
            )
    
    # Handle patient_id conversion
    if 'patient_id' in update_dict and update_dict['patient_id']:
        try:
            update_dict['patient_id'] = UUID(update_dict['patient_id'])
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid patient_id format"
            )
    
    updated_case = repo.update(case, update_dict)
    
    return CaseResponse(
        id=str(updated_case.id),
        requesting_doctor_id=str(updated_case.requesting_doctor_id),
        patient_id=str(updated_case.patient_id) if updated_case.patient_id else None,
        title=updated_case.title,
        chief_complaint=updated_case.chief_complaint,
        history=updated_case.history,
        physical_exam_notes=updated_case.physical_exam_notes,
        urgency=updated_case.urgency,
        status=updated_case.status,
        assigned_volunteer_id=str(updated_case.assigned_volunteer_id) if updated_case.assigned_volunteer_id else None,
        priority_score=updated_case.priority_score,
        created_at=updated_case.created_at,
        updated_at=updated_case.updated_at,
        submitted_at=updated_case.submitted_at,
        is_offline=updated_case.is_offline
    )


@router.delete("/{case_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_case(
    case_id: str,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete a case"""
    repo = CaseRepository(db)
    
    if current_user.role != 'requesting_doctor':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only requesting doctors can delete cases"
        )
    
    case = repo.get_by_id(case_id, doctor_id=current_user.id)
    if not case:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Case not found"
        )
    
    repo.delete(case)
    return None


@router.post("/sync")
async def sync_offline_cases(db: Session = Depends(get_db)):
    """Sync offline queue"""
    # TODO: Implement offline sync
    raise HTTPException(status_code=501, detail="Not implemented yet")

