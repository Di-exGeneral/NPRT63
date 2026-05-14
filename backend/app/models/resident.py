from sqlalchemy import Column, String, ForeignKey
from app.database import Base

class Resident(Base):
    __tablename__ = "residents"

    residentID = Column(String(36), primary_key=True, nullable=False)
    userID = Column(String(36), ForeignKey("users.userID"), nullable=False)
    areaID = Column(String(36), ForeignKey("area.areaID"), nullable=False)