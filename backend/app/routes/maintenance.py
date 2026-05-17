from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from app.database import get_db
from app.services.maintenance_service import create_assignment, get_assignments_by_team, get_assignment_by_report
from app.services.audit_service import log_action
from app.middleware.auth_middleware import get_current_user, require_role

router = APIRouter()

@router.post("/assign")
def assign_team(reportID: str, teamID: str, assignedBy: str, db: Session = Depends(get_db), current_user: dict = Depends(require_role("MunicipalAdmin"))):
    try:
        result = create_assignment(db, reportID, teamID, assignedBy)
        log_action(db, current_user["sub"], "MAINTENANCE_ASSIGNED", f"ReportID: {reportID}, TeamID: {teamID}")
        return result
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=404, detail="Report or team not found")

@router.get("/team/{teamID}", dependencies=[Depends(require_role("MaintenanceTeam", "MunicipalAdmin"))])
def get_team_assignments(teamID: str, db: Session = Depends(get_db)):
    return get_assignments_by_team(db, teamID)

@router.get("/report/{reportID}", dependencies=[Depends(get_current_user)])
def get_report_assignment(reportID: str, db: Session = Depends(get_db)):
    return get_assignment_by_report(db, reportID)