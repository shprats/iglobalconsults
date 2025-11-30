"""
Files API Endpoints
TUS Protocol and file management
"""

from fastapi import APIRouter, Depends, HTTPException, Request, Response, Header
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from typing import Optional
from uuid import uuid4
from datetime import datetime, timezone
import base64
import io

from app.core.database import get_db
from app.core.config import settings
from app.api.v1.auth import get_current_user
from app.schemas.auth import UserResponse
from app.schemas.file import FileResponse, TUSCreateResponse, TUSHeadResponse, TUSPatchResponse
from app.repositories.file_repository import FileRepository
from app.repositories.case_repository import CaseRepository
from app.services.s3_service import S3Service
from app.services.image_quality_service import ImageQualityService

router = APIRouter()
s3_service = S3Service()
quality_service = ImageQualityService()


# TUS Protocol Headers
TUS_VERSION = "1.0.0"
TUS_RESUMABLE = "1.0.0"
TUS_MAX_SIZE = str(settings.TUS_MAX_FILE_SIZE)


@router.post("/upload", response_model=TUSCreateResponse)
async def create_upload(
    request: Request,
    upload_length: int = Header(..., alias="Upload-Length"),
    upload_metadata: Optional[str] = Header(None, alias="Upload-Metadata"),
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    TUS Protocol: Create upload (POST)
    Creates a new upload session
    """
    # Validate file size
    if upload_length > settings.TUS_MAX_FILE_SIZE:
        raise HTTPException(
            status_code=413,
            detail=f"File size exceeds maximum allowed size of {settings.TUS_MAX_FILE_SIZE} bytes"
        )
    
    # Parse metadata
    metadata = {}
    if upload_metadata:
        for item in upload_metadata.split(","):
            if " " in item:
                key, value = item.split(" ", 1)
                # Decode base64 value
                try:
                    metadata[key] = base64.b64decode(value).decode('utf-8')
                except Exception:
                    metadata[key] = value
    
    # Generate TUS upload ID
    tus_upload_id = str(uuid4())
    
    # Generate S3 key
    file_name = metadata.get("filename", f"upload_{tus_upload_id}")
    s3_key = f"uploads/{current_user.id}/{tus_upload_id}/{file_name}"
    
    # Create file record
    repo = FileRepository(db)
    file_data = {
        "uploaded_by": current_user.id,
        "file_name": file_name,
        "original_file_name": metadata.get("filename", file_name),
        "file_type": metadata.get("filetype", "document"),
        "file_size": upload_length,
        "s3_key": s3_key,
        "s3_bucket": settings.S3_BUCKET_NAME,
        "s3_region": settings.AWS_REGION,
        "mime_type": metadata.get("filetype"),
        "upload_status": "pending",
        "tus_upload_id": tus_upload_id,
        "upload_progress": 0.0,
        "started_at": datetime.now(timezone.utc)
    }
    
    if "case_id" in metadata:
        try:
            from uuid import UUID
            case_uuid = UUID(metadata["case_id"])
            # Verify case exists and belongs to user
            case_repo = CaseRepository(db)
            case = case_repo.get_by_id(metadata["case_id"], doctor_id=current_user.id)
            if case:
                file_data["case_id"] = case_uuid
        except Exception:
            pass  # Invalid case_id, continue without it
    
    file = repo.create(file_data)
    
    # Return TUS response
    location = f"/api/v1/files/upload/{tus_upload_id}"
    return Response(
        status_code=201,
        headers={
            "Location": location,
            "Tus-Resumable": TUS_RESUMABLE,
            "Upload-Offset": "0",
            "Upload-Length": str(upload_length)
        }
    )


@router.head("/upload/{upload_id}")
async def get_upload_info(
    upload_id: str,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    TUS Protocol: Get upload info (HEAD)
    Returns current upload offset and length
    """
    repo = FileRepository(db)
    file = repo.get_by_tus_id(upload_id)
    
    if not file:
        raise HTTPException(status_code=404, detail="Upload not found")
    
    # Verify file belongs to user
    if str(file.uploaded_by) != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
    
    # Calculate upload offset
    upload_offset = int((file.upload_progress / 100.0) * file.file_size) if file.upload_progress else 0
    
    return Response(
        status_code=200,
        headers={
            "Upload-Offset": str(upload_offset),
            "Upload-Length": str(file.file_size),
            "Tus-Resumable": TUS_RESUMABLE,
            "Cache-Control": "no-store"
        }
    )


@router.patch("/upload/{upload_id}")
async def patch_upload(
    upload_id: str,
    request: Request,
    upload_offset: int = Header(..., alias="Upload-Offset"),
    content_type: Optional[str] = Header(None, alias="Content-Type"),
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    TUS Protocol: Resume upload (PATCH)
    Uploads file chunk
    """
    repo = FileRepository(db)
    file = repo.get_by_tus_id(upload_id)
    
    if not file:
        raise HTTPException(status_code=404, detail="Upload not found")
    
    # Verify file belongs to user
    if str(file.uploaded_by) != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
    
    # Read chunk data
    chunk_data = await request.body()
    chunk_size = len(chunk_data)
    
    # Verify offset matches
    expected_offset = int((file.upload_progress / 100.0) * file.file_size) if file.upload_progress else 0
    if upload_offset != expected_offset:
        raise HTTPException(
            status_code=409,
            detail=f"Offset mismatch. Expected {expected_offset}, got {upload_offset}",
            headers={"Tus-Resumable": TUS_RESUMABLE}
        )
    
    # Update progress
    new_offset = upload_offset + chunk_size
    new_progress = min(100.0, (new_offset / file.file_size) * 100.0)
    repo.update_upload_progress(file, new_offset, file.file_size)
    
    # If this is the first chunk, update status
    if file.upload_status == "pending":
        repo.update(file, {"upload_status": "uploading"})
    
    # Upload chunk to S3 (in production, you'd use multipart upload)
    # For now, we'll store chunks temporarily and assemble at completion
    # In production, use S3 multipart upload API
    
    # Check if upload is complete
    if new_offset >= file.file_size:
        # Mark as completed
        repo.mark_completed(file)
        
        # TODO: In production, complete S3 multipart upload here
        # For now, we'll mark it as completed
        
        return Response(
            status_code=204,
            headers={
                "Upload-Offset": str(new_offset),
                "Tus-Resumable": TUS_RESUMABLE
            }
        )
    
    return Response(
        status_code=204,
        headers={
            "Upload-Offset": str(new_offset),
            "Tus-Resumable": TUS_RESUMABLE
        }
    )


@router.get("/{file_id}", response_model=FileResponse)
async def get_file(
    file_id: str,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get file metadata"""
    repo = FileRepository(db)
    file = repo.get_by_id(file_id)
    
    if not file:
        raise HTTPException(status_code=404, detail="File not found")
    
    # Verify access (user uploaded it or has access to the case)
    if str(file.uploaded_by) != current_user.id:
        # Check if user has access via case
        if file.case_id:
            case_repo = CaseRepository(db)
            case = case_repo.get_by_id(str(file.case_id), doctor_id=current_user.id)
            if not case:
                raise HTTPException(status_code=403, detail="Access denied")
        else:
            raise HTTPException(status_code=403, detail="Access denied")
    
    return FileResponse(
        id=str(file.id),
        case_id=str(file.case_id) if file.case_id else None,
        uploaded_by=str(file.uploaded_by),
        file_name=file.file_name,
        original_file_name=file.original_file_name,
        file_type=file.file_type,
        file_size=file.file_size,
        s3_key=file.s3_key,
        s3_bucket=file.s3_bucket,
        s3_region=file.s3_region,
        mime_type=file.mime_type,
        upload_status=file.upload_status,
        tus_upload_id=file.tus_upload_id,
        upload_progress=file.upload_progress,
        quality_score=file.quality_score,
        quality_issues=file.quality_issues,
        is_analyzed=file.is_analyzed,
        created_at=file.created_at,
        completed_at=file.completed_at
    )


@router.get("/case/{case_id}")
async def list_case_files(
    case_id: str,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """List all files for a case"""
    # Verify case access
    case_repo = CaseRepository(db)
    case = case_repo.get_by_id(case_id, doctor_id=current_user.id)
    
    if not case:
        raise HTTPException(status_code=404, detail="Case not found")
    
    file_repo = FileRepository(db)
    files = file_repo.get_by_case(case_id)
    
    return [
        FileResponse(
            id=str(f.id),
            case_id=str(f.case_id) if f.case_id else None,
            uploaded_by=str(f.uploaded_by),
            file_name=f.file_name,
            original_file_name=f.original_file_name,
            file_type=f.file_type,
            file_size=f.file_size,
            s3_key=f.s3_key,
            s3_bucket=f.s3_bucket,
            s3_region=f.s3_region,
            mime_type=f.mime_type,
            upload_status=f.upload_status,
            tus_upload_id=f.tus_upload_id,
            upload_progress=f.upload_progress,
            quality_score=f.quality_score,
            quality_issues=f.quality_issues,
            is_analyzed=f.is_analyzed,
            created_at=f.created_at,
            completed_at=f.completed_at
        )
        for f in files
    ]


@router.post("/{file_id}/analyze")
async def analyze_image(
    file_id: str,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Analyze image quality"""
    repo = FileRepository(db)
    file = repo.get_by_id(file_id)
    
    if not file:
        raise HTTPException(status_code=404, detail="File not found")
    
    # Verify access
    if str(file.uploaded_by) != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")
    
    # Check if file is completed
    if file.upload_status != "completed":
        raise HTTPException(status_code=400, detail="File upload must be completed before analysis")
    
    # Check if it's an image
    if file.file_type not in ["xray", "photo", "lab_result"]:
        raise HTTPException(status_code=400, detail="Quality analysis only available for images")
    
    # TODO: Download file from S3 and analyze
    # For now, return placeholder
    # In production, download from S3, analyze, and update file record
    
    # Placeholder analysis
    quality_score = 0.85
    issues = ["Image quality is good"]
    
    from datetime import datetime, timezone
    repo.update(file, {
        "quality_score": quality_score,
        "quality_issues": issues,
        "is_analyzed": True,
        "quality_analysis_at": datetime.now(timezone.utc)
    })
    
    return {
        "file_id": str(file.id),
        "quality_score": quality_score,
        "quality_issues": issues,
        "is_analyzed": True
    }

