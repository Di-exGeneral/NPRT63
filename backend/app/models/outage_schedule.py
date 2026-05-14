from sqlalchemy import Column, String, Text, DateTime, ForeignKey
from app.database import Base

class OutageSchedule(Base):
    __tablename__ = "outageschedule"

    scheduleID = Column(String(36), primary_key=True, nullable=False)
    areaID = Column(String(36), ForeignKey("area.areaID"), nullable=False)
    startTime = Column(DateTime, nullable=False)
    endTime = Column(DateTime, nullable=False)
    description = Column(Text, nullable=True)
    status = Column(String(50), nullable=False)
    createdBy = Column(String(36), ForeignKey("users.userID"), nullable=False)