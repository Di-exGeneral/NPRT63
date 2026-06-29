from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.user import UserUpdate
from app.services.user_service import get_all_users, get_user_by_id, delete_user
from app.middleware.auth_middleware import get_current_user, require_role

router = APIRouter()

@router.get("/", dependencies=[Depends(require_role("ITStaff"))])
def list_users(db: Session = Depends(get_db)):
    return get_all_users(db)


@router.get("/me", dependencies=[Depends(get_current_user)])
def get_me(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    user = get_user_by_id(db, current_user["sub"])
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.get("/me/resident", dependencies=[Depends(get_current_user)])
def get_my_resident_profile(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    from app.models.resident import Resident
    resident = db.query(Resident).filter(Resident.userID == current_user["sub"]).first()
    if not resident:
        raise HTTPException(status_code=404, detail="Resident profile not found")
    return resident

@router.patch("/me")
def update_me(updates: UserUpdate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    user = get_user_by_id(db, current_user["sub"])
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if updates.username is not None:
        user.username = updates.username
    if updates.phoneNumber is not None:
        user.phoneNumber = updates.phoneNumber
    db.commit()
    db.refresh(user)
    return user

@router.get("/{userID}", dependencies=[Depends(get_current_user)])
def get_user(userID: str, db: Session = Depends(get_db)):
    user = get_user_by_id(db, userID)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.delete("/{userID}", dependencies=[Depends(require_role("ITStaff"))])
def remove_user(userID: str, db: Session = Depends(get_db)):
    delete_user(db, userID)
    return {"message": "User deleted successfully"}
