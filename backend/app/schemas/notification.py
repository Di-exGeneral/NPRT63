from pydantic import BaseModel
from datetime import datetime

class NotificationCreate(BaseModel):
    notificationID: str
    userID: str
    title: str
    message: str
    type: str = "general"

class NotificationResponse(BaseModel):
    notificationID: str
    userID: str
    title: str
    message: str
    type: str
    isRead: bool
    createdAt: datetime

    class Config:
        from_attributes = True
