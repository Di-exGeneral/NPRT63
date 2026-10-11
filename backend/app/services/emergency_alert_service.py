from sqlalchemy.orm import Session
from app.models.emergency_alert import EmergencyAlert
from app.models.notification import Notification
from app.models.resident import Resident
from app.models.user import User
from app.models.area import Area
from app.services.sns_service import send_sms
import uuid

def notify_area_residents(db: Session, areaID: str, title: str, message: str, type: str, sms: bool = True) -> int:
    """Create an in-app notification (and optionally an SMS) for every resident in an area.
    Returns the number of residents notified."""
    users = (
        db.query(User)
        .join(Resident, Resident.userID == User.userID)
        .filter(Resident.areaID == areaID)
        .all()
    )
    for user in users:
        db.add(Notification(
            notificationID=str(uuid.uuid4()),
            userID=user.userID,
            title=title[:255],
            message=message[:500],
            type=type,
            isRead=False
        ))
    db.commit()
    if sms:
        for user in users:
            if user.phoneNumber:
                try:
                    send_sms(user.phoneNumber, f"HydroAlert: {message}")
                except Exception:
                    pass
    return len(users)

def serialize_alert(db: Session, alert: EmergencyAlert) -> dict:
    area = db.query(Area).filter(Area.areaID == alert.areaID).first()
    return {
        "alertID": alert.alertID,
        "areaID": alert.areaID,
        "areaName": area.suburbName if area else None,
        "alertType": alert.alertType,
        "message": alert.message,
        "estimatedDuration": alert.estimatedDuration,
        "channels": [c for c in alert.channels.split(",") if c],
        "sentBy": alert.sentBy,
        "recipientCount": alert.recipientCount,
        "createdAt": alert.createdAt,
    }

def send_emergency_alert(db: Session, areaID: str, alertType: str, message: str, estimatedDuration, channels, sentBy: str) -> EmergencyAlert:
    body = message if not estimatedDuration else f"{message} (Estimated duration: {estimatedDuration})"
    channels = [c.lower() for c in channels]
    count = notify_area_residents(db, areaID, f"Emergency: {alertType}", body, "emergency", sms="sms" in channels)
    alert = EmergencyAlert(
        alertID=str(uuid.uuid4()),
        areaID=areaID,
        alertType=alertType,
        message=message,
        estimatedDuration=estimatedDuration,
        channels=",".join(channels),
        sentBy=sentBy,
        recipientCount=count
    )
    db.add(alert)
    db.commit()
    db.refresh(alert)
    return alert

def get_recent_alerts(db: Session, limit: int = 50):
    return db.query(EmergencyAlert).order_by(EmergencyAlert.createdAt.desc()).limit(limit).all()
