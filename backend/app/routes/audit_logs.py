from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.services.audit_service import get_all_logs, get_logs_by_user

router = APIRouter()

@router.get("/")
def list_logs(db: Session = Depends(get_db)):
    return get_all_logs(db)

@router.get("/user/{userID}")
def get_user_logs(userID: str, db: Session = Depends(get_db)):
    return get_logs_by_user(db, userID)