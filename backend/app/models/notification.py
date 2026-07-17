from sqlalchemy import Column, String, Boolean, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.database import Base

class Notification(Base):
    __tablename__ = "notifications"

    notificationID = Column(String(36), primary_key=True, nullable=False)
    userID = Column(String(36), ForeignKey("users.userid"), nullable=False)
    title = Column(String(255), nullable=False)
    message = Column(String(500), nullable=False)
    type = Column(String(50), nullable=False, default="general")
    isRead = Column(Boolean, nullable=False, default=False)
    createdAt = Column(DateTime, server_default=func.now(), nullable=False)
