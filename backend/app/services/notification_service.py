from sqlalchemy.orm import Session
from app.models.notification import Notification
import uuid

def create_notification(db: Session, userID: str, title: str, message: str, type: str = "general") -> Notification:
    notification = Notification(
        notificationID=str(uuid.uuid4()),
        userID=userID,
        title=title,
        message=message,
        type=type,
        isRead=False
    )
    db.add(notification)
    db.commit()
    db.refresh(notification)
    return notification

def get_notifications_by_user(db: Session, userID: str):
    return db.query(Notification).filter(Notification.userID == userID).order_by(Notification.createdAt.desc()).all()

def mark_as_read(db: Session, notificationID: str) -> Notification:
    notification = db.query(Notification).filter(Notification.notificationID == notificationID).first()
    if notification:
        notification.isRead = True
        db.commit()
        db.refresh(notification)
    return notification

def mark_all_as_read(db: Session, userID: str):
    db.query(Notification).filter(Notification.userID == userID).update({"isRead": True})
    db.commit()
