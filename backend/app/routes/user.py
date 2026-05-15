from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.services.user_service import get_all_users, get_user_by_id, delete_user

router = APIRouter()

@router.get("/")
def list_users(db: Session = Depends(get_db)):
    return get_all_users(db)

@router.get("/{userID}")
def get_user(userID: str, db: Session = Depends(get_db)):
    user = get_user_by_id(db, userID)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.delete("/{userID}")
def remove_user(userID: str, db: Session = Depends(get_db)):
    delete_user(db, userID)
    return {"message": "User deleted successfully"}