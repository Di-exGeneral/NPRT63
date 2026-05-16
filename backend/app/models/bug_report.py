from sqlalchemy import Column, String, Text, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.database import Base

class BugReport(Base):
    __tablename__ = "bugreport"

    bugID = Column(String(36), primary_key=True, nullable=False)
    userID = Column(String(36), ForeignKey("users.userid"), nullable=False)
    managedBy = Column(String(36), ForeignKey("users.userid"), nullable=True)
    title = Column(String(150), nullable=False)
    description = Column(Text, nullable=False)
    screenshot = Column(String(500), nullable=True)
    status = Column(String(50), nullable=False)
    submittedAt = Column(DateTime, server_default=func.now(), nullable=False)
    resolvedAt = Column(DateTime, nullable=True)