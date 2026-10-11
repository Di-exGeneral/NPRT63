from sqlalchemy.orm import Session
from app.models.fault_report import FaultReport
from app.models.report_history import ReportHistory
from app.models.resident import Resident
from app.models.area import Area
from app.models.user import User
from app.models.photo import Photo
from app.schemas.fault_report import FaultReportCreate
import uuid

def serialize_fault_report(db: Session, report: FaultReport) -> dict:
    """Convert a FaultReport row into a dict that includes human-readable
    resident and area names so admin/mobile clients don't show raw IDs."""
    data = {
        "reportID": report.reportID,
        "title": report.title,
        "residentID": report.residentID,
        "areaID": report.areaID,
        "description": report.description,
        "status": report.status,
        "location": report.location,
        "timestamp": report.timestamp,
        "residentName": None,
        "areaName": None,
        "photos": [p.photoURL for p in db.query(Photo).filter(Photo.reportID == report.reportID).all()],
    }
    resident = db.query(Resident).filter(Resident.residentID == report.residentID).first()
    if resident:
        user = db.query(User).filter(User.userID == resident.userID).first()
        if user:
            data["residentName"] = user.username
    area = db.query(Area).filter(Area.areaID == report.areaID).first()
    if area:
        data["areaName"] = area.suburbName
    return data

def create_fault_report(db: Session, report: FaultReportCreate) -> FaultReport:
    new_report = FaultReport(
        reportID=str(uuid.uuid4()),
        title=report.title,
        residentID=report.residentID,
        areaID=report.areaID,
        description=report.description,
        status="Submitted",
        location=report.location
    )
    db.add(new_report)
    db.commit()
    db.refresh(new_report)
    return new_report

def get_all_fault_reports(db: Session):
    reports = db.query(FaultReport).order_by(FaultReport.timestamp.desc()).all()
    return [serialize_fault_report(db, r) for r in reports]

def get_fault_report_by_id(db: Session, reportID: str):
    report = db.query(FaultReport).filter(FaultReport.reportID == reportID).first()
    if not report:
        return None
    return serialize_fault_report(db, report)

def get_reports_by_resident(db: Session, residentID: str):
    reports = db.query(FaultReport).filter(FaultReport.residentID == residentID).all()
    return [serialize_fault_report(db, r) for r in reports]

def update_fault_report_status(db: Session, reportID: str, newStatus: str, changedBy: str):
    report = db.query(FaultReport).filter(FaultReport.reportID == reportID).first()
    if report:
        history = ReportHistory(
            historyID=str(uuid.uuid4()),
            reportID=reportID,
            previousStatus=report.status,
            newStatus=newStatus,
            changedBy=changedBy
        )
        db.add(history)
        report.status = newStatus
        db.commit()
        db.refresh(report)
        return serialize_fault_report(db, report)
    return report

def get_report_history(db: Session, reportID: str):
    return db.query(ReportHistory).filter(ReportHistory.reportID == reportID).all()
