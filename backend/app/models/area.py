from sqlalchemy import Column, String
from app.database import Base

class Area(Base):
    __tablename__ = "area"

    areaID = Column(String(36), primary_key=True, nullable=False)
    suburbName = Column(String(100), nullable=False)
    municipalityName = Column(String(100), nullable=False)