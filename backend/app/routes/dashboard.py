from datetime import datetime
from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session
from app.database import get_db
from app.middleware.auth_middleware import require_role
from app.models.area import Area
from app.models.fault_report import FaultReport
from app.models.outage_schedule import OutageSchedule
from app.models.maintenance_team import MaintenanceTeam
from app.models.emergency_alert import EmergencyAlert

router = APIRouter()

@router.get("/summary", dependencies=[Depends(require_role("MunicipalAdmin", "ITStaff"))])
def get_summary(db: Session = Depends(get_db)):
    now = datetime.utcnow()
    reports_by_status = dict(db.query(FaultReport.status, func.count()).group_by(FaultReport.status).all())
    schedules_by_status = dict(db.query(OutageSchedule.status, func.count()).group_by(OutageSchedule.status).all())
    ongoing_outages = db.query(OutageSchedule).filter(
        OutageSchedule.startTime <= now,
        OutageSchedule.endTime >= now,
        OutageSchedule.status.notin_(["Cancelled", "Completed"])
    ).count()
    upcoming_outages = db.query(OutageSchedule).filter(
        OutageSchedule.startTime > now,
        OutageSchedule.status.notin_(["Cancelled", "Completed"])
    ).count()
    return {
        "totalReports": sum(reports_by_status.values()),
        "reportsByStatus": reports_by_status,
        "totalSchedules": sum(schedules_by_status.values()),
        "schedulesByStatus": schedules_by_status,
        "ongoingOutages": ongoing_outages,
        "upcomingOutages": upcoming_outages,
        "areas": db.query(Area).count(),
        "maintenanceTeams": db.query(MaintenanceTeam).count(),
        "alertsSent": db.query(EmergencyAlert).count(),
    }
