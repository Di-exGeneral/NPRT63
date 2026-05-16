from sqlalchemy import Column, String, CheckConstraint
from app.database import Base

class User(Base):
    __tablename__ = "users"

    userID = Column("userid", String(36), primary_key=True, nullable=False)
    username = Column(String(100), nullable=False)
    email = Column(String(150), nullable=False, unique=True)
    phoneNumber = Column("phonenumber", String(20), nullable=False)
    password = Column(String(255), nullable=False)
    role = Column(String(50), nullable=False)