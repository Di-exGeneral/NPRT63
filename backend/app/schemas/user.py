from pydantic import BaseModel, EmailStr
from typing import Optional

class UserCreate(BaseModel):
    username: str
    email: EmailStr
    phoneNumber: str
    password: str
    role: str

class UserResponse(BaseModel):
    userID: str
    username: str
    email: str
    phoneNumber: str
    role: str

    class Config:
        from_attributes = True

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    role: str

class UserUpdate(BaseModel):
    username: Optional[str] = None
    phoneNumber: Optional[str] = None
