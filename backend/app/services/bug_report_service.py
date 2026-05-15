from sqlalchemy.orm import Session
from app.models.bug_report import BugReport
from app.schemas.bug_report import BugReportCreate, BugReportUpdate
from datetime import datetime
import uuid

def create_bug_report(db: Session, bug: BugReportCreate, userID: str, screenshot: str = None) -> BugReport:
    new_bug = BugReport(
        bugID=str(uuid.uuid4()),
        userID=userID,
        title=bug.title,
        description=bug.description,
        screenshot=screenshot,
        status="Submitted"
    )
    db.add(new_bug)
    db.commit()
    db.refresh(new_bug)
    return new_bug

def get_all_bug_reports(db: Session):
    return db.query(BugReport).all()

def get_bug_report_by_id(db: Session, bugID: str) -> BugReport:
    return db.query(BugReport).filter(BugReport.bugID == bugID).first()

def update_bug_status(db: Session, bugID: str, update: BugReportUpdate) -> BugReport:
    bug = db.query(BugReport).filter(BugReport.bugID == bugID).first()
    if bug:
        bug.status = update.status
        bug.managedBy = update.managedBy
        if update.status == "Resolved":
            bug.resolvedAt = datetime.utcnow()
        db.commit()
        db.refresh(bug)
    return bug