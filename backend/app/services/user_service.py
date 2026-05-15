from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.user import UserCreate
from app.services.auth_service import hash_password
import uuid

def create_user(db: Session, user: UserCreate) -> User:
    new_user = User(
        userID=str(uuid.uuid4()),
        username=user.username,
        email=user.email,
        phoneNumber=user.phoneNumber,
        password=hash_password(user.password),
        role=user.role
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

def get_user_by_email(db: Session, email: str) -> User:
    return db.query(User).filter(User.email == email).first()

def get_user_by_id(db: Session, userID: str) -> User:
    return db.query(User).filter(User.userID == userID).first()

def get_all_users(db: Session):
    return db.query(User).all()

def delete_user(db: Session, userID: str):
    user = db.query(User).filter(User.userID == userID).first()
    if user:
        db.delete(user)
        db.commit()