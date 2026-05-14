from sqlalchemy import Column, String, ForeignKey
from app.database import Base

class ITStaff(Base):
    __tablename__ = "itstaff"

    staffID = Column(String(36), primary_key=True, nullable=False)
    userID = Column(String(36), ForeignKey("users.userID"), nullable=False)