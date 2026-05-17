from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.bug_report import BugReportCreate, BugReportUpdate
from app.services.bug_report_service import create_bug_report, get_all_bug_reports, get_bug_report_by_id, update_bug_status
from app.services.s3_service import upload_photo
from app.services.audit_service import log_action
from app.middleware.auth_middleware import get_current_user, require_role

router = APIRouter()

@router.post("/")
def submit_bug(bug: BugReportCreate, userID: str, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    new_bug = create_bug_report(db, bug, userID)
    log_action(db, current_user["sub"], "BUG_REPORT_SUBMITTED", f"Title: {bug.title}")
    return new_bug

@router.post("/{bugID}/screenshot")
def upload_screenshot(bugID: str, file: UploadFile = File(...), db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    url = upload_photo(file, folder="screenshots")
    bug = get_bug_report_by_id(db, bugID)
    if not bug:
        raise HTTPException(status_code=404, detail="Bug report not found")
    bug.screenshot = url
    db.commit()
    return {"screenshotURL": url}

@router.get("/", dependencies=[Depends(require_role("ITStaff"))])
def list_bugs(db: Session = Depends(get_db)):
    return get_all_bug_reports(db)

@router.get("/{bugID}", dependencies=[Depends(get_current_user)])
def get_bug(bugID: str, db: Session = Depends(get_db)):
    bug = get_bug_report_by_id(db, bugID)
    if not bug:
        raise HTTPException(status_code=404, detail="Bug report not found")
    return bug

@router.patch("/{bugID}/status")
def update_status(bugID: str, update: BugReportUpdate, db: Session = Depends(get_db), current_user: dict = Depends(require_role("ITStaff"))):
    result = update_bug_status(db, bugID, update)
    log_action(db, current_user["sub"], "BUG_STATUS_UPDATED", f"BugID: {bugID}, Status: {update.status}")
    return result