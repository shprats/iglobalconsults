"""
Cases API Endpoints
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db

router = APIRouter()


@router.post("/")
async def create_case(db: Session = Depends(get_db)):
    """Create a new case"""
    # TODO: Implement case creation
    raise HTTPException(status_code=501, detail="Not implemented yet")


@router.get("/")
async def list_cases(db: Session = Depends(get_db)):
    """List cases for current user"""
    # TODO: Implement case listing
    raise HTTPException(status_code=501, detail="Not implemented yet")


@router.get("/{case_id}")
async def get_case(case_id: str, db: Session = Depends(get_db)):
    """Get case by ID"""
    # TODO: Implement get case
    raise HTTPException(status_code=501, detail="Not implemented yet")


@router.post("/sync")
async def sync_offline_cases(db: Session = Depends(get_db)):
    """Sync offline queue"""
    # TODO: Implement offline sync
    raise HTTPException(status_code=501, detail="Not implemented yet")

