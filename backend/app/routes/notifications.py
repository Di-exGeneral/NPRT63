from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.services.notification_service import get_notifications_by_user, mark_as_read, mark_all_as_read
from app.middleware.auth_middleware import get_current_user

router = APIRouter()

@router.get("/", dependencies=[Depends(get_current_user)])
def get_my_notifications(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_notifications_by_user(db, current_user["sub"])

@router.patch("/{notificationID}/read", dependencies=[Depends(get_current_user)])
def read_notification(notificationID: str, db: Session = Depends(get_db)):
    return mark_as_read(db, notificationID)

@router.patch("/read-all", dependencies=[Depends(get_current_user)])
def read_all_notifications(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    mark_all_as_read(db, current_user["sub"])
    return {"message": "All notifications marked as read"}
