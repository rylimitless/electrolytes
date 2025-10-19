"""
User models and database configuration for authentication system.
"""

import os
from datetime import datetime, timedelta
from typing import Optional
from enum import Enum

from pydantic import BaseModel, Field, EmailStr
from motor.motor_asyncio import AsyncIOMotorClient
from passlib.context import CryptContext
from jose import JWTError, jwt

# Password hashing context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT settings
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-change-in-production")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# MongoDB settings
MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
DATABASE_NAME = os.getenv("DATABASE_NAME", "electrolytes_auth")

class AccountStatus(str, Enum):
    ACTIVE = "active"
    SUSPENDED = "suspended"
    PENDING_VERIFICATION = "pending_verification"

class UserRole(str, Enum):
    USER = "user"
    ADMIN = "admin"

class SecurityQuestion(str, Enum):
    PET_NAME = "What was the name of your first pet?"
    MOTHER_MAIDEN = "What is your mother's maiden name?"
    FIRST_SCHOOL = "What was the name of your first school?"
    CHILDHOOD_CITY = "In what city did you spend most of your childhood?"
    FAVORITE_TEACHER = "Who was your favorite teacher?"
    FIRST_CAR = "What was the make and model of your first car?"

class UserInDB(BaseModel):
    """User model for database storage"""
    username: str = Field(..., min_length=3, max_length=50)
    email: Optional[EmailStr] = None
    hashed_password: str
    security_question: SecurityQuestion
    hashed_security_answer: str
    role: UserRole = UserRole.USER
    status: AccountStatus = AccountStatus.ACTIVE
    created_at: datetime
    updated_at: datetime
    last_login: Optional[datetime] = None

class UserCreate(BaseModel):
    """User creation model"""
    username: str = Field(..., min_length=3, max_length=50)
    email: Optional[EmailStr] = None
    password: str = Field(..., min_length=6)
    security_question: SecurityQuestion
    security_answer: str = Field(..., min_length=1)

class UserLogin(BaseModel):
    """User login model"""
    username: str
    password: str

class SecurityQuestionVerify(BaseModel):
    """Security question verification model"""
    username: str
    security_answer: str

class PasswordReset(BaseModel):
    """Password reset model"""
    username: str
    security_answer: str
    new_password: str = Field(..., min_length=6)

class UserResponse(BaseModel):
    """User response model (without sensitive data)"""
    username: str
    email: Optional[EmailStr]
    role: UserRole
    status: AccountStatus
    created_at: datetime
    last_login: Optional[datetime]

class Token(BaseModel):
    """JWT token response"""
    access_token: str
    token_type: str
    expires_in: int

class TokenData(BaseModel):
    """JWT token payload"""
    username: Optional[str] = None

# Database connection
class Database:
    def __init__(self):
        self.client: Optional[AsyncIOMotorClient] = None
        self.database = None

    async def connect(self):
        """Connect to MongoDB"""
        try:
            self.client = AsyncIOMotorClient(MONGODB_URL)
            self.database = self.client[DATABASE_NAME]

            # Test the connection
            await self.client.admin.command('ping')
            print(f"Connected to MongoDB: {MONGODB_URL}")
        except Exception as e:
            print(f"Error connecting to MongoDB: {e}")
            raise

    async def disconnect(self):
        """Disconnect from MongoDB"""
        if self.client:
            self.client.close()
            print("Disconnected from MongoDB")

# Global database instance
db = Database()

# Password hashing utilities
def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against its hash"""
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """Hash a password"""
    return pwd_context.hash(password)

# JWT utilities
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    """Create JWT access token"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)

    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_token(token: str) -> Optional[TokenData]:
    """Verify JWT token"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            return None
        return TokenData(username=username)
    except JWTError:
        return None