from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.bug_report import BugReportCreate, BugReportUpdate
from app.services.bug_report_service import create_bug_report, get_all_bug_reports, get_bug_report_by_id, update_bug_status
from app.services.s3_service import upload_photo

router = APIRouter()

@router.post("/")
def submit_bug(bug: BugReportCreate, userID: str, db: Session = Depends(get_db)):
    return create_bug_report(db, bug, userID)

@router.post("/{bugID}/screenshot")
def upload_screenshot(bugID: str, file: UploadFile = File(...), db: Session = Depends(get_db)):
    url = upload_photo(file, folder="screenshots")
    bug = get_bug_report_by_id(db, bugID)
    if not bug:
        raise HTTPException(status_code=404, detail="Bug report not found")
    bug.screenshot = url
    db.commit()
    return {"screenshotURL": url}

@router.get("/")
def list_bugs(db: Session = Depends(get_db)):
    return get_all_bug_reports(db)

@router.get("/{bugID}")
def get_bug(bugID: str, db: Session = Depends(get_db)):
    bug = get_bug_report_by_id(db, bugID)
    if not bug:
        raise HTTPException(status_code=404, detail="Bug report not found")
    return bug

@router.patch("/{bugID}/status")
def update_status(bugID: str, update: BugReportUpdate, db: Session = Depends(get_db)):
    return update_bug_status(db, bugID, update)