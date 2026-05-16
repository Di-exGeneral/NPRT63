from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.services.audit_service import get_all_logs, get_logs_by_user
from app.middleware.auth_middleware import require_role

router = APIRouter()

@router.get("/", dependencies=[Depends(require_role("ITStaff"))])
def list_logs(db: Session = Depends(get_db)):
    return get_all_logs(db)

@router.get("/user/{userID}", dependencies=[Depends(require_role("ITStaff"))])
def get_user_logs(userID: str, db: Session = Depends(get_db)):
    return get_logs_by_user(db, userID)