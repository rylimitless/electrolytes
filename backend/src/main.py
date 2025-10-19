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
from contextlib import asynccontextmanager

from fastapi import FastAPI, File, UploadFile, HTTPException, Form, Query, Depends, status
from fastapi.responses import JSONResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import uvicorn

# Import authentication models and utilities
from models import (
    UserCreate, UserLogin, UserResponse, Token, SecurityQuestionVerify,
    PasswordReset, UserInDB, UserRole, AccountStatus, SecurityQuestion,
    db, get_password_hash, verify_password, create_access_token,
    verify_token, TokenData, ACCESS_TOKEN_EXPIRE_MINUTES
)


# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Lifespan context manager for database connection
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    await db.connect()
    yield
    # Shutdown
    await db.disconnect()

# Create FastAPI app
app = FastAPI(
    title="Electrolytes API",
    description="FastAPI backend with authentication and image CRUD operations",
    version="1.0.0",
    lifespan=lifespan
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


# Authentication endpoints
@app.post("/auth/register", response_model=UserResponse)
async def register_user(user_data: UserCreate):
    """Register a new user"""
    try:
        # Check if user already exists
        existing_user = await db.database.users.find_one({"username": user_data.username})
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username already registered"
            )

        # Check if email already exists (if provided)
        if user_data.email:
            existing_email = await db.database.users.find_one({"email": user_data.email})
            if existing_email:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Email already registered"
                )

        # Hash password and security answer
        hashed_password = get_password_hash(user_data.password)
        hashed_security_answer = get_password_hash(user_data.security_answer)

        # Create user document
        user_doc = UserInDB(
            username=user_data.username,
            email=user_data.email,
            hashed_password=hashed_password,
            security_question=user_data.security_question,
            hashed_security_answer=hashed_security_answer,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )

        # Convert to dict for MongoDB insertion
        user_dict = user_doc.dict()
        
        # Insert user into database
        result = await db.database.users.insert_one(user_dict)
        
        if not result.inserted_id:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to create user"
            )

        # Return user data (without sensitive information)
        return UserResponse(
            username=user_doc.username,
            email=user_doc.email,
            role=user_doc.role,
            status=user_doc.status,
            created_at=user_doc.created_at,
            last_login=user_doc.last_login
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error registering user: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )

@app.post("/auth/login", response_model=Token)
async def login_user(user_credentials: UserLogin):
    """Authenticate user and return JWT token"""
    try:
        # Find user in database
        user = await db.database.users.find_one({"username": user_credentials.username})
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect username or password"
            )

        # Verify password
        if not verify_password(user_credentials.password, user["hashed_password"]):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect username or password"
            )

        # Check if account is active
        if user.get("status") != AccountStatus.ACTIVE:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Account is not active"
            )

        # Update last login
        await db.database.users.update_one(
            {"username": user_credentials.username},
            {"$set": {"last_login": datetime.utcnow()}}
        )

        # Create access token
        access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": user_credentials.username}, expires_delta=access_token_expires
        )

        return Token(
            access_token=access_token,
            token_type="bearer",
            expires_in=ACCESS_TOKEN_EXPIRE_MINUTES * 60
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error during login: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )

@app.post("/auth/verify-security-question")
async def verify_security_question(security_data: SecurityQuestionVerify):
    """Verify security question answer for account recovery"""
    try:
        # Find user in database
        user = await db.database.users.find_one({"username": security_data.username})
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        # Verify security answer
        if not verify_password(security_data.security_answer, user["hashed_security_answer"]):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect security answer"
            )

        return {"message": "Security question verified successfully"}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error verifying security question: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )

@app.post("/auth/reset-password")
async def reset_password(reset_data: PasswordReset):
    """Reset password using security question"""
    try:
        # Find user in database
        user = await db.database.users.find_one({"username": reset_data.username})
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        # Verify security answer
        if not verify_password(reset_data.security_answer, user["hashed_security_answer"]):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect security answer"
            )

        # Hash new password
        hashed_new_password = get_password_hash(reset_data.new_password)

        # Update password in database
        result = await db.database.users.update_one(
            {"username": reset_data.username},
            {
                "$set": {
                    "hashed_password": hashed_new_password,
                    "updated_at": datetime.utcnow()
                }
            }
        )

        if result.modified_count == 0:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to update password"
            )

        return {"message": "Password reset successfully"}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error resetting password: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )

@app.get("/auth/me", response_model=UserResponse)
async def get_current_user(token: str = Depends(HTTPBearer())):
    """Get current user information"""
    try:
        # Verify token
        credentials: HTTPAuthorizationCredentials = token
        token_data = verify_token(credentials.credentials)
        
        if not token_data or not token_data.username:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication credentials"
            )

        # Find user in database
        user = await db.database.users.find_one({"username": token_data.username})
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        # Return user data (without sensitive information)
        return UserResponse(
            username=user["username"],
            email=user.get("email"),
            role=user["role"],
            status=user["status"],
            created_at=user["created_at"],
            last_login=user.get("last_login")
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting current user: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )