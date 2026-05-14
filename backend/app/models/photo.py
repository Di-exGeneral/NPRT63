from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.database import Base

class Photo(Base):
    __tablename__ = "photo"

    photoID = Column(String(36), primary_key=True, nullable=False)
    reportID = Column(String(36), ForeignKey("faultreport.reportID"), nullable=False)
    photoURL = Column(String(500), nullable=False)
    uploadedAt = Column(DateTime, server_default=func.now(), nullable=False)