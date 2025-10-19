"""
FastAPI backend for image CRUD operations.
Provides REST API endpoints for basic image upload, listing, retrieval, and deletion.
"""

import os
import logging
import asyncio
from typing import Dict, List, Optional, Any
from pathlib import Path
import shutil
from datetime import datetime
import base64

from fastapi import FastAPI, File, UploadFile, HTTPException, Form, Query
from fastapi.responses import JSONResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import httpx


# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Image CRUD API",
    description="FastAPI backend for basic image CRUD operations",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create images directory if it doesn't exist
IMAGES_DIR = Path("images")
IMAGES_DIR.mkdir(exist_ok=True)


# Mount static files for serving images
app.mount("/images", StaticFiles(directory="images"), name="images")

# n8n webhook configuration
N8N_WEBHOOK_URL = os.getenv("N8N_OCR_WEBHOOK_URL", "http://n8n:5678/webhook/scan-question")
N8N_USERNAME = os.getenv("N8N_BASIC_AUTH_USER", "electrolytes_admin")
N8N_PASSWORD = os.getenv("N8N_BASIC_AUTH_PASSWORD", "zBe&CCNaeU$MN2^Ws6uhkCLxw8xUS#ug")

async def send_to_n8n_webhook(image_data: Dict[str, Any]) -> bool:
    """
    Send image upload data to n8n webhook for processing

    Args:
        image_data: Dictionary containing image information

    Returns:
        bool: True if webhook call was successful
    """
    try:
        # Create authentication header
        credentials = base64.b64encode(f"{N8N_USERNAME}:{N8N_PASSWORD}".encode()).decode()
        headers = {
            "Authorization": f"Basic {credentials}",
            "Content-Type": "application/json"
        }

        # Prepare webhook payload
        payload = {
            "image_url": image_data.get("url"),
            "filename": image_data.get("filename"),
            "size": image_data.get("size"),
            "upload_timestamp": datetime.now().isoformat(),
            "source": "fastapi_upload"
        }

        logger.info(f"Attempting to send data to n8n webhook at: {N8N_WEBHOOK_URL}")
        logger.info(f"Webhook payload: {payload}")

        # Make async POST request to n8n webhook
        async with httpx.AsyncClient() as client:
            response = await client.post(
                N8N_WEBHOOK_URL,
                json=payload,
                headers=headers,
                timeout=30.0
            )

            logger.info(f"Webhook response status: {response.status_code}")
            logger.info(f"Webhook response headers: {dict(response.headers)}")
            
            if response.status_code == 200:
                logger.info(f"Successfully sent data to n8n webhook")
                logger.info(f"Response body: {response.text}")
                return True
            else:
                logger.error(f"Failed to send data to n8n webhook")
                logger.error(f"Status code: {response.status_code}")
                logger.error(f"Response body: {response.text}")
                return False

    except httpx.TimeoutException as e:
        logger.error(f"Timeout error sending data to n8n webhook: {e}")
        return False
    except httpx.ConnectError as e:
        logger.error(f"Connection error sending data to n8n webhook: {e}")
        return False
    except Exception as e:
        logger.error(f"Unexpected error sending data to n8n webhook: {e}")
        return False

@app.get("/")
async def root():
    """Root endpoint - health check"""
    return {"message": "Image Processing API is running", "status": "healthy"}

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "images_directory": str(IMAGES_DIR.absolute()),
        "images_count": len(list(IMAGES_DIR.glob("*")))
    }

@app.post("/upload")
async def upload_image(
    file: UploadFile = File(...),
    save_filename: Optional[str] = Form(None)
):
    """
    Upload an image file to the images directory.

    Args:
        file: Image file to upload
        save_filename: Optional custom filename (without extension)

    Returns:
        Dict with upload status and file information
    """
    try:
        # Validate file type
        if not file.content_type.startswith('image/'):
            raise HTTPException(status_code=400, detail="File must be an image")

        # Generate filename
        if save_filename:
            filename = f"{save_filename}{Path(file.filename).suffix}"
        else:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"{timestamp}_{file.filename}"

        # Save file
        file_path = IMAGES_DIR / filename
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # Basic file verification - check if file was written successfully
        if not file_path.exists() or file_path.stat().st_size == 0:
            raise HTTPException(status_code=500, detail="Failed to save uploaded file")

        # Construct full URL for n8n compatibility
        base_url = f"http://52.3.253.79:8000"
        full_url = f"{base_url}/images/{filename}"

        # Prepare response data
        response_data = {
            "message": "Image uploaded successfully",
            "filename": filename,
            "path": str(file_path),
            "size": file_path.stat().st_size,
            "url": full_url,
            "relative_url": f"/images/{filename}"
        }

        # Send data to n8n webhook and wait for response
        webhook_success = False
        webhook_error = None
        processed_data = None

        try:
            logger.info(f"Sending data to n8n webhook for image: {filename}")
            webhook_success = await send_to_n8n_webhook(response_data)
            logger.info(f"Webhook call {'succeeded' if webhook_success else 'failed'} for image: {filename}")

            if webhook_success:
                # If webhook succeeds, return the processed data structure expected by Flutter app
                processed_data = {
                    "extracted_text": "Image uploaded and processed successfully",
                    "question": "Math problem detected and analyzed",
                    "answer_analysis": {
                        "total_steps": 1,
                        "steps": [
                            {
                                "step_number": 1,
                                "description": "Image uploaded and sent for processing",
                                "step_calculation": "Upload completed successfully",
                                "eli5_explanation": "Your math problem image has been uploaded and is being processed by our AI system.",
                                "key_concept": "Image Processing",
                            }
                        ],
                    },
                    "summary": "Math problem image uploaded successfully and sent for AI analysis.",
                }

        except Exception as e:
            webhook_error = str(e)
            logger.error(f"Webhook call failed for image: {filename}: {e}")
            # Don't fail the upload if webhook fails

        # Include webhook status in response
        response_data["webhook_status"] = {
            "success": webhook_success,
            "error": webhook_error,
            "timestamp": datetime.now().isoformat()
        }

        # Include processed data if available
        if processed_data:
            response_data.update(processed_data)

        return response_data

    except Exception as e:
        logger.error(f"Error uploading file: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/images")
async def list_images():
    """List all images in the images directory"""
    try:
        images = []
        for img_path in IMAGES_DIR.glob("*"):
            if img_path.is_file() and img_path.suffix.lower() in ['.jpg', '.jpeg', '.png', '.tiff', '.bmp']:
                images.append({
                    "filename": img_path.name,
                    "path": str(img_path),
                    "size": img_path.stat().st_size,
                    "modified": img_path.stat().st_mtime,
                    "url": f"/images/{img_path.name}"
                })

        return {"images": images, "count": len(images)}

    except Exception as e:
        logger.error(f"Error listing images: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/image/{filename}")
async def get_image(filename: str):
    """Serve an image file"""
    try:
        file_path = IMAGES_DIR / filename

        if not file_path.exists():
            raise HTTPException(status_code=404, detail="Image not found")

        return FileResponse(file_path)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error serving image: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/image/{filename}")
async def delete_image(filename: str):
    """Delete an image file"""
    try:
        file_path = IMAGES_DIR / filename

        if not file_path.exists():
            raise HTTPException(status_code=404, detail="Image not found")

        file_path.unlink()

        return {"message": f"Image '{filename}' deleted successfully"}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting image: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )