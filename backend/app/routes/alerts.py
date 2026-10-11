from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.emergency_alert import EmergencyAlertCreate
from app.services.emergency_alert_service import send_emergency_alert, get_recent_alerts, serialize_alert
from app.services.area_service import get_area_by_id
from app.services.audit_service import log_action
from app.middleware.auth_middleware import require_role

router = APIRouter()

@router.post("/")
def create_alert(alert: EmergencyAlertCreate, db: Session = Depends(get_db), current_user: dict = Depends(require_role("MunicipalAdmin"))):
    if not get_area_by_id(db, alert.areaID):
        raise HTTPException(status_code=404, detail="Area not found")
    new_alert = send_emergency_alert(db, alert.areaID, alert.alertType, alert.message, alert.estimatedDuration, alert.channels, current_user["sub"])
    log_action(db, current_user["sub"], "EMERGENCY_ALERT_SENT", f"AlertID: {new_alert.alertID}, Area: {alert.areaID}, Recipients: {new_alert.recipientCount}")
    return serialize_alert(db, new_alert)

@router.get("/", dependencies=[Depends(require_role("MunicipalAdmin", "ITStaff"))])
def list_alerts(limit: int = 50, db: Session = Depends(get_db)):
    return [serialize_alert(db, a) for a in get_recent_alerts(db, limit)]
