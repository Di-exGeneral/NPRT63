from sqlalchemy.orm import Session
from app.models.fault_report import FaultReport
from app.models.report_history import ReportHistory
from app.schemas.fault_report import FaultReportCreate
import uuid

def create_fault_report(db: Session, report: FaultReportCreate) -> FaultReport:
    new_report = FaultReport(
        reportID=str(uuid.uuid4()),
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
    return db.query(FaultReport).all()

def get_fault_report_by_id(db: Session, reportID: str) -> FaultReport:
    return db.query(FaultReport).filter(FaultReport.reportID == reportID).first()

def get_reports_by_resident(db: Session, residentID: str):
    return db.query(FaultReport).filter(FaultReport.residentID == residentID).all()

def update_fault_report_status(db: Session, reportID: str, newStatus: str, changedBy: str) -> FaultReport:
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
    return report

def get_report_history(db: Session, reportID: str):
    return db.query(ReportHistory).filter(ReportHistory.reportID == reportID).all()