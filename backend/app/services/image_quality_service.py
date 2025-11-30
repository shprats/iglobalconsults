"""
Image Quality Service
Analyzes medical images for quality issues
"""

import cv2
import numpy as np
from PIL import Image
from typing import List, Tuple, Optional
import io
import logging

logger = logging.getLogger(__name__)


class ImageQualityService:
    """Analyze image quality for medical images"""
    
    @staticmethod
    def analyze_image(image_data: bytes) -> Tuple[float, List[str]]:
        """
        Analyze image quality
        Returns: (quality_score, issues_list)
        quality_score: 0.0 to 1.0 (1.0 = perfect quality)
        issues: List of quality issues found
        """
        issues = []
        score = 1.0
        
        try:
            # Convert bytes to numpy array
            nparr = np.frombuffer(image_data, np.uint8)
            img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            if img is None:
                return 0.0, ["Invalid image format"]
            
            # Check image dimensions
            height, width = img.shape[:2]
            if width < 512 or height < 512:
                issues.append("Image resolution too low (minimum 512x512 recommended)")
                score -= 0.2
            
            # Check for blur (Laplacian variance)
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            laplacian_var = cv2.Laplacian(gray, cv2.CV_64F).var()
            
            if laplacian_var < 100:
                issues.append("Image appears blurry")
                score -= 0.3
            elif laplacian_var < 200:
                issues.append("Image may be slightly blurry")
                score -= 0.1
            
            # Check brightness
            mean_brightness = np.mean(gray)
            if mean_brightness < 50:
                issues.append("Image too dark")
                score -= 0.2
            elif mean_brightness > 200:
                issues.append("Image too bright (may be overexposed)")
                score -= 0.1
            
            # Check contrast
            contrast = np.std(gray)
            if contrast < 30:
                issues.append("Low contrast - image may be difficult to analyze")
                score -= 0.2
            
            # Check for noise
            # Simple noise estimation using standard deviation of Laplacian
            if laplacian_var > 500:
                issues.append("Image may have excessive noise")
                score -= 0.1
            
            # Ensure score is between 0 and 1
            score = max(0.0, min(1.0, score))
            
            if not issues:
                issues.append("Image quality is good")
            
            return score, issues
            
        except Exception as e:
            logger.error(f"Error analyzing image quality: {e}")
            return 0.0, [f"Error analyzing image: {str(e)}"]
    
    @staticmethod
    def is_valid_medical_image(image_data: bytes, mime_type: str) -> bool:
        """Check if image is a valid medical image format"""
        valid_types = [
            'image/jpeg',
            'image/png',
            'image/dicom',
            'application/dicom'
        ]
        return mime_type.lower() in valid_types

