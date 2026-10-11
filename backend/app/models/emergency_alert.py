from sqlalchemy import Column, String, Text, Integer, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.database import Base

class EmergencyAlert(Base):
    __tablename__ = "emergencyalert"

    alertID = Column(String(36), primary_key=True, nullable=False)
    areaID = Column(String(36), ForeignKey("area.areaID"), nullable=False)
    alertType = Column(String(100), nullable=False)
    message = Column(Text, nullable=False)
    estimatedDuration = Column(String(100), nullable=True)
    channels = Column(String(255), nullable=False, default="push")
    sentBy = Column(String(36), ForeignKey("users.userid"), nullable=False)
    recipientCount = Column(Integer, nullable=False, default=0)
    createdAt = Column(DateTime, server_default=func.now(), nullable=False)
