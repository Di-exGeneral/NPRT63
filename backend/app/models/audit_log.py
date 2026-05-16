from sqlalchemy import Column, String, Text, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.database import Base

class AuditLog(Base):
    __tablename__ = "auditlog"

    logID = Column(String(36), primary_key=True, nullable=False)
    userID = Column(String(36), ForeignKey("users.userid"), nullable=False)
    action = Column(String(255), nullable=False)
    timestamp = Column(DateTime, server_default=func.now(), nullable=False)
    details = Column(Text, nullable=True)