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
from uuid import uuid4

from fastapi import FastAPI, File, UploadFile, HTTPException, Form, Query, Body
from fastapi.responses import JSONResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import uvicorn
import httpx
from motor.motor_asyncio import AsyncIOMotorClient
from pymongo import ASCENDING, DESCENDING


# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Mathix Tutor API",
    description="FastAPI backend for image operations and chat functionality",
    version="1.0.0"
)

# MongoDB configuration
MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://n8n_chat_app:chatAppPass123@localhost:27017/n8n_chat_db?authSource=admin")
mongo_client: Optional[AsyncIOMotorClient] = None
mongo_db = None

# Chat Models
class ChatMessage(BaseModel):
    text: str
    session_id: Optional[str] = None
    user_id: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None

class ChatResponse(BaseModel):
    message_id: str
    session_id: str
    user_message: str
    assistant_message: Optional[str] = None
    timestamp: datetime
    processing: bool = False

class ChatHistoryResponse(BaseModel):
    session_id: str
    messages: List[Dict[str, Any]]
    total_count: int

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
N8N_CHAT_WEBHOOK_URL = os.getenv("N8N_CHAT_WEBHOOK_URL", "http://n8n:5678/webhook/chat")
N8N_USERNAME = os.getenv("N8N_BASIC_AUTH_USER", "electrolytes_admin")
N8N_PASSWORD = os.getenv("N8N_BASIC_AUTH_PASSWORD", "zBe&CCNaeU$MN2^Ws6uhkCLxw8xUS#ug")

# MongoDB connection management
@app.on_event("startup")
async def startup_db_client():
    """Initialize MongoDB connection on startup"""
    global mongo_client, mongo_db
    try:
        mongo_client = AsyncIOMotorClient(MONGODB_URL)
        mongo_db = mongo_client.n8n_chat_db
        # Test connection
        await mongo_client.admin.command('ping')
        logger.info("Successfully connected to MongoDB")
    except Exception as e:
        logger.error(f"Failed to connect to MongoDB: {e}")
        # Don't fail startup, just log the error
        mongo_client = None
        mongo_db = None

@app.on_event("shutdown")
async def shutdown_db_client():
    """Close MongoDB connection on shutdown"""
    global mongo_client
    if mongo_client:
        mongo_client.close()
        logger.info("MongoDB connection closed")

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
        try:
            logger.info(f"Sending data to n8n webhook for image: {filename}")
            webhook_success = await send_to_n8n_webhook(response_data)
            logger.info(f"Webhook call {'succeeded' if webhook_success else 'failed'} for image: {filename}")
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

# ============== CHAT ENDPOINTS ==============

async def send_to_n8n_chat_webhook(session_id: str, message: str, user_id: Optional[str] = None) -> Optional[str]:
    """
    Send chat message to n8n webhook for AI processing
    
    Args:
        session_id: Unique session identifier
        message: User's message text
        user_id: Optional user identifier
        
    Returns:
        str: AI response or None if failed
    """
    try:
        credentials = base64.b64encode(f"{N8N_USERNAME}:{N8N_PASSWORD}".encode()).decode()
        headers = {
            "Authorization": f"Basic {credentials}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "sessionId": session_id,
            "message": message,
            "userId": user_id,
            "timestamp": datetime.now().isoformat()
        }
        
        logger.info(f"Sending message to n8n chat webhook for session: {session_id}")
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                N8N_CHAT_WEBHOOK_URL,
                json=payload,
                headers=headers,
                timeout=30.0
            )
            
            if response.status_code == 200:
                result = response.json()
                logger.info(f"Successfully received AI response for session: {session_id}")
                logger.info(f"n8n response: {result}")
                
                # Handle different n8n response formats
                # Format 1: [{"output": "text"}]
                if isinstance(result, list) and len(result) > 0:
                    if "output" in result[0]:
                        return result[0]["output"]
                    elif "message" in result[0]:
                        return result[0]["message"]
                
                # Format 2: {"response": "text"} or {"message": "text"}
                if isinstance(result, dict):
                    return result.get("response", result.get("message", result.get("output", "I received your message!")))
                
                # Fallback
                logger.warning(f"Unexpected n8n response format: {result}")
                return "I received your message!"
            else:
                logger.error(f"n8n webhook returned status {response.status_code}")
                logger.error(f"Response body: {response.text}")
                return None
                
    except Exception as e:
        logger.error(f"Error sending to n8n chat webhook: {e}")
        return None

@app.post("/chat/send", response_model=ChatResponse)
async def send_chat_message(message: ChatMessage):
    """
    Send a chat message and get AI response
    
    Args:
        message: ChatMessage containing text, session_id, and optional metadata
        
    Returns:
        ChatResponse with message IDs and AI response
    """
    if not mongo_db:
        raise HTTPException(status_code=503, detail="Database connection not available")
    
    try:
        # Generate session_id if not provided
        session_id = message.session_id or str(uuid4())
        user_id = message.user_id or "anonymous"
        message_id = str(uuid4())
        timestamp = datetime.now()
        
        # Store user message in MongoDB
        user_message_doc = {
            "message_id": message_id,
            "session_id": session_id,
            "user_id": user_id,
            "conversation_id": session_id,
            "message_content": message.text,
            "message_type": "user",
            "timestamp": timestamp,
            "metadata": message.metadata or {},
        }
        
        await mongo_db.n8n_chat_histories.insert_one(user_message_doc)
        logger.info(f"Stored user message: {message_id}")
        
        # Send to n8n for AI processing (async, don't wait)
        ai_response = await send_to_n8n_chat_webhook(session_id, message.text, user_id)
        
        # Store AI response if we got one
        if ai_response:
            ai_message_id = str(uuid4())
            ai_message_doc = {
                "message_id": ai_message_id,
                "session_id": session_id,
                "user_id": "assistant",
                "conversation_id": session_id,
                "message_content": ai_response,
                "message_type": "assistant",
                "timestamp": datetime.now(),
                "metadata": {
                    "in_reply_to": message_id
                },
            }
            await mongo_db.n8n_chat_histories.insert_one(ai_message_doc)
            logger.info(f"Stored AI response: {ai_message_id}")
        
        return ChatResponse(
            message_id=message_id,
            session_id=session_id,
            user_message=message.text,
            assistant_message=ai_response,
            timestamp=timestamp,
            processing=ai_response is None
        )
        
    except Exception as e:
        logger.error(f"Error processing chat message: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/chat/history/{session_id}", response_model=ChatHistoryResponse)
async def get_chat_history(
    session_id: str,
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0)
):
    """
    Get chat history for a specific session
    
    Args:
        session_id: Session identifier
        limit: Maximum number of messages to return (1-200)
        offset: Number of messages to skip
        
    Returns:
        ChatHistoryResponse with messages and count
    """
    if not mongo_db:
        raise HTTPException(status_code=503, detail="Database connection not available")
    
    try:
        # Get messages for this session, sorted by timestamp
        cursor = mongo_db.n8n_chat_histories.find(
            {"session_id": session_id}
        ).sort("timestamp", ASCENDING).skip(offset).limit(limit)
        
        messages = []
        async for doc in cursor:
            # Convert MongoDB document to dict, handling ObjectId
            doc.pop("_id", None)  # Remove MongoDB _id field
            messages.append(doc)
        
        # Get total count
        total_count = await mongo_db.n8n_chat_histories.count_documents(
            {"session_id": session_id}
        )
        
        return ChatHistoryResponse(
            session_id=session_id,
            messages=messages,
            total_count=total_count
        )
        
    except Exception as e:
        logger.error(f"Error retrieving chat history: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/chat/sessions")
async def list_chat_sessions(
    user_id: Optional[str] = Query(None),
    limit: int = Query(20, ge=1, le=100)
):
    """
    List recent chat sessions
    
    Args:
        user_id: Optional filter by user_id
        limit: Maximum number of sessions to return
        
    Returns:
        List of session information
    """
    if not mongo_db:
        raise HTTPException(status_code=503, detail="Database connection not available")
    
    try:
        # Build query filter
        match_filter = {}
        if user_id:
            match_filter["user_id"] = user_id
        
        # Aggregate to get unique sessions with last message time
        pipeline = [
            {"$match": match_filter} if match_filter else {"$match": {}},
            {"$sort": {"timestamp": DESCENDING}},
            {"$group": {
                "_id": "$session_id",
                "last_message": {"$first": "$message_content"},
                "last_timestamp": {"$first": "$timestamp"},
                "message_count": {"$sum": 1}
            }},
            {"$sort": {"last_timestamp": DESCENDING}},
            {"$limit": limit}
        ]
        
        sessions = []
        async for doc in mongo_db.n8n_chat_histories.aggregate(pipeline):
            sessions.append({
                "session_id": doc["_id"],
                "last_message": doc["last_message"],
                "last_timestamp": doc["last_timestamp"],
                "message_count": doc["message_count"]
            })
        
        return {"sessions": sessions, "count": len(sessions)}
        
    except Exception as e:
        logger.error(f"Error listing chat sessions: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/chat/session/{session_id}")
async def delete_chat_session(session_id: str):
    """
    Delete all messages in a chat session
    
    Args:
        session_id: Session identifier to delete
        
    Returns:
        Deletion status
    """
    if not mongo_db:
        raise HTTPException(status_code=503, detail="Database connection not available")
    
    try:
        result = await mongo_db.n8n_chat_histories.delete_many(
            {"session_id": session_id}
        )
        
        return {
            "message": f"Deleted session {session_id}",
            "deleted_count": result.deleted_count
        }
        
    except Exception as e:
        logger.error(f"Error deleting chat session: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )