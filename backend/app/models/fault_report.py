from sqlalchemy import Column, String, Text, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.database import Base

class FaultReport(Base):
    __tablename__ = "faultreport"

    title = Column(String(255), nullable=False, server_default='Untitled')
    reportID = Column(String(36), primary_key=True, nullable=False)
    residentID = Column(String(36), ForeignKey("residents.residentID"), nullable=False)
    areaID = Column(String(36), ForeignKey("area.areaID"), nullable=False)
    description = Column(Text, nullable=False)
    status = Column(String(50), nullable=False)
    location = Column(String(255), nullable=False)
    timestamp = Column(DateTime, server_default=func.now(), nullable=False)
