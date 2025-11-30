"""
AWS S3 Service
Handles file uploads to S3
"""

import boto3
from botocore.exceptions import ClientError
from typing import Optional, BinaryIO
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)


class S3Service:
    def __init__(self):
        self.s3_client = None
        if settings.AWS_ACCESS_KEY_ID and settings.AWS_SECRET_ACCESS_KEY:
            self.s3_client = boto3.client(
                's3',
                aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
                aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
                region_name=settings.AWS_REGION
            )
        else:
            logger.warning("AWS credentials not configured. S3 operations will be disabled.")
    
    def upload_file(
        self,
        file_obj: BinaryIO,
        s3_key: str,
        bucket: Optional[str] = None,
        content_type: Optional[str] = None
    ) -> bool:
        """Upload file to S3"""
        if not self.s3_client:
            logger.error("S3 client not initialized")
            return False
        
        bucket = bucket or settings.S3_BUCKET_NAME
        try:
            extra_args = {}
            if content_type:
                extra_args['ContentType'] = content_type
            
            if settings.S3_USE_TRANSFER_ACCELERATION:
                extra_args['ServerSideEncryption'] = 'AES256'
            
            self.s3_client.upload_fileobj(
                file_obj,
                bucket,
                s3_key,
                ExtraArgs=extra_args
            )
            logger.info(f"File uploaded to S3: s3://{bucket}/{s3_key}")
            return True
        except ClientError as e:
            logger.error(f"Error uploading to S3: {e}")
            return False
    
    def get_presigned_url(
        self,
        s3_key: str,
        bucket: Optional[str] = None,
        expiration: int = 3600
    ) -> Optional[str]:
        """Generate presigned URL for file access"""
        if not self.s3_client:
            return None
        
        bucket = bucket or settings.S3_BUCKET_NAME
        try:
            url = self.s3_client.generate_presigned_url(
                'get_object',
                Params={'Bucket': bucket, 'Key': s3_key},
                ExpiresIn=expiration
            )
            return url
        except ClientError as e:
            logger.error(f"Error generating presigned URL: {e}")
            return None
    
    def delete_file(
        self,
        s3_key: str,
        bucket: Optional[str] = None
    ) -> bool:
        """Delete file from S3"""
        if not self.s3_client:
            return False
        
        bucket = bucket or settings.S3_BUCKET_NAME
        try:
            self.s3_client.delete_object(Bucket=bucket, Key=s3_key)
            logger.info(f"File deleted from S3: s3://{bucket}/{s3_key}")
            return True
        except ClientError as e:
            logger.error(f"Error deleting from S3: {e}")
            return False

