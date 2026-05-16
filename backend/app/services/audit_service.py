from sqlalchemy.orm import Session
from app.models.audit_log import AuditLog
import uuid

def log_action(db: Session, userID: str, action: str, details: str = None):
    log = AuditLog(
        logID=str(uuid.uuid4()),
        userID=userID,
        action=action,
        details=details
    )
    db.add(log)
    db.commit()

def get_all_logs(db: Session):
    return db.query(AuditLog).all()

def get_logs_by_user(db: Session, userID: str):
    return db.query(AuditLog).filter(AuditLog.userID == userID).all()