from sqlalchemy.orm import Session
from app.models.maintenance_assignment import MaintenanceAssignment
import uuid

def create_assignment(db: Session, reportID: str, teamID: str, assignedBy: str) -> MaintenanceAssignment:
    assignment = MaintenanceAssignment(
        assignmentID=str(uuid.uuid4()),
        reportID=reportID,
        teamID=teamID,
        assignedBy=assignedBy
    )
    db.add(assignment)
    db.commit()
    db.refresh(assignment)
    return assignment

def get_assignments_by_team(db: Session, teamID: str):
    return db.query(MaintenanceAssignment).filter(MaintenanceAssignment.teamID == teamID).all()

def get_assignment_by_report(db: Session, reportID: str) -> MaintenanceAssignment:
    return db.query(MaintenanceAssignment).filter(MaintenanceAssignment.reportID == reportID).first()