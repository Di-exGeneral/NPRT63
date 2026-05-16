from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.database import Base

class MaintenanceAssignment(Base):
    __tablename__ = "maintenanceassignment"

    assignmentID = Column(String(36), primary_key=True, nullable=False)
    reportID = Column(String(36), ForeignKey("faultreport.reportID"), nullable=False)
    teamID = Column(String(36), ForeignKey("maintenanceteam.teamID"), nullable=False)
    assignedBy = Column(String(36), ForeignKey("users.userid"), nullable=False)
    assignedAt = Column(DateTime, server_default=func.now(), nullable=False)