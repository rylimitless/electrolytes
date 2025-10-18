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

from fastapi import FastAPI, File, UploadFile, HTTPException, Form, Query
from fastapi.responses import JSONResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
import uvicorn


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

        return {
            "message": "Image uploaded successfully",
            "filename": filename,
            "path": str(file_path),
            "size": file_path.stat().st_size,
            "url": f"/images/{filename}"
        }

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