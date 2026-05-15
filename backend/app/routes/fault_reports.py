from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.fault_report import FaultReportCreate, FaultReportUpdate
from app.services.fault_report_service import create_fault_report, get_all_fault_reports, get_fault_report_by_id, get_reports_by_resident, update_fault_report_status, get_report_history
from app.services.s3_service import upload_photo
from app.models.photo import Photo
import uuid

router = APIRouter()

@router.post("/")
def submit_report(report: FaultReportCreate, db: Session = Depends(get_db)):
    return create_fault_report(db, report)

@router.get("/")
def list_reports(db: Session = Depends(get_db)):
    return get_all_fault_reports(db)

@router.get("/{reportID}")
def get_report(reportID: str, db: Session = Depends(get_db)):
    report = get_fault_report_by_id(db, reportID)
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    return report

@router.get("/resident/{residentID}")
def get_resident_reports(residentID: str, db: Session = Depends(get_db)):
    return get_reports_by_resident(db, residentID)

@router.patch("/{reportID}/status")
def update_status(reportID: str, update: FaultReportUpdate, changedBy: str, db: Session = Depends(get_db)):
    return update_fault_report_status(db, reportID, update.status, changedBy)

@router.get("/{reportID}/history")
def get_history(reportID: str, db: Session = Depends(get_db)):
    return get_report_history(db, reportID)

@router.post("/{reportID}/photos")
def upload_report_photo(reportID: str, file: UploadFile = File(...), db: Session = Depends(get_db)):
    url = upload_photo(file)
    photo = Photo(
        photoID=str(uuid.uuid4()),
        reportID=reportID,
        photoURL=url
    )
    db.add(photo)
    db.commit()
    return {"photoURL": url}