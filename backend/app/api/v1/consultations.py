"""
Consultations API Endpoints
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db

router = APIRouter()


@router.post("/{consultation_id}/start")
async def start_consultation(consultation_id: str, db: Session = Depends(get_db)):
    """Start a consultation"""
    # TODO: Implement start consultation
    raise HTTPException(status_code=501, detail="Not implemented yet")


@router.post("/{consultation_id}/end")
async def end_consultation(consultation_id: str, db: Session = Depends(get_db)):
    """End a consultation"""
    # TODO: Implement end consultation
    raise HTTPException(status_code=501, detail="Not implemented yet")

