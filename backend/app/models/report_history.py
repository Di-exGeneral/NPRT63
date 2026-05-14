from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.database import Base

class ReportHistory(Base):
    __tablename__ = "reporthistory"

    historyID = Column(String(36), primary_key=True, nullable=False)
    reportID = Column(String(36), ForeignKey("faultreport.reportID"), nullable=False)
    previousStatus = Column(String(50), nullable=False)
    newStatus = Column(String(50), nullable=False)
    changedBy = Column(String(36), ForeignKey("users.userID"), nullable=False)
    changedAt = Column(DateTime, server_default=func.now(), nullable=False)