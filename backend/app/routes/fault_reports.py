from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.fault_report import FaultReportCreate, FaultReportUpdate
from app.services.fault_report_service import create_fault_report, get_all_fault_reports, get_fault_report_by_id, get_reports_by_resident, update_fault_report_status, get_report_history
from app.services.s3_service import upload_photo
from app.services.audit_service import log_action
from app.middleware.auth_middleware import get_current_user, require_role
from app.models.photo import Photo
import uuid

router = APIRouter()

@router.post("/")
def submit_report(report: FaultReportCreate, db: Session = Depends(get_db), current_user: dict = Depends(require_role("Resident"))):
    new_report = create_fault_report(db, report)
    log_action(db, current_user["sub"], "FAULT_REPORT_SUBMITTED", f"ReportID: {new_report.reportID}, Area: {report.areaID}")
    return new_report

@router.get("/", dependencies=[Depends(require_role("MunicipalAdmin", "ITStaff"))])
def list_reports(db: Session = Depends(get_db)):
    return get_all_fault_reports(db)

@router.get("/{reportID}", dependencies=[Depends(get_current_user)])
def get_report(reportID: str, db: Session = Depends(get_db)):
    report = get_fault_report_by_id(db, reportID)
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    return report

@router.get("/resident/{residentID}", dependencies=[Depends(require_role("Resident"))])
def get_resident_reports(residentID: str, db: Session = Depends(get_db)):
    return get_reports_by_resident(db, residentID)

@router.patch("/{reportID}/status")
def update_status(reportID: str, update: FaultReportUpdate, changedBy: str, db: Session = Depends(get_db), current_user: dict = Depends(require_role("MunicipalAdmin", "MaintenanceTeam"))):
    result = update_fault_report_status(db, reportID, update.status, changedBy)
    log_action(db, current_user["sub"], "FAULT_REPORT_STATUS_UPDATED", f"ReportID: {reportID}, Status: {update.status}")
    return result

@router.get("/{reportID}/history", dependencies=[Depends(get_current_user)])
def get_history(reportID: str, db: Session = Depends(get_db)):
    return get_report_history(db, reportID)

@router.post("/{reportID}/photos")
def upload_report_photo(reportID: str, file: UploadFile = File(...), db: Session = Depends(get_db), current_user: dict = Depends(require_role("Resident"))):
    url = upload_photo(file)
    photo = Photo(
        photoID=str(uuid.uuid4()),
        reportID=reportID,
        photoURL=url
    )
    db.add(photo)
    db.commit()
    log_action(db, current_user["sub"], "PHOTO_UPLOADED", f"ReportID: {reportID}")
    return {"photoURL": url}