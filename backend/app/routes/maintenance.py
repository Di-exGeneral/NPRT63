from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.services.maintenance_service import create_assignment, get_assignments_by_team, get_assignment_by_report

router = APIRouter()

@router.post("/assign")
def assign_team(reportID: str, teamID: str, assignedBy: str, db: Session = Depends(get_db)):
    return create_assignment(db, reportID, teamID, assignedBy)

@router.get("/team/{teamID}")
def get_team_assignments(teamID: str, db: Session = Depends(get_db)):
    return get_assignments_by_team(db, teamID)

@router.get("/report/{reportID}")
def get_report_assignment(reportID: str, db: Session = Depends(get_db)):
    return get_assignment_by_report(db, reportID)