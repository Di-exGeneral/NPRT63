from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.outage_schedule import OutageScheduleCreate, OutageScheduleUpdate
from app.services.outage_schedule_service import create_outage_schedule, get_all_schedules, get_schedules_by_area, get_schedule_by_id, update_schedule_status, delete_schedule
from app.middleware.auth_middleware import get_current_user, require_role

router = APIRouter()

@router.post("/", dependencies=[Depends(require_role("MunicipalAdmin"))])
def add_schedule(schedule: OutageScheduleCreate, db: Session = Depends(get_db)):
    return create_outage_schedule(db, schedule)

@router.get("/", dependencies=[Depends(get_current_user)])
def list_schedules(db: Session = Depends(get_db)):
    return get_all_schedules(db)

@router.get("/area/{areaID}", dependencies=[Depends(get_current_user)])
def get_area_schedules(areaID: str, db: Session = Depends(get_db)):
    return get_schedules_by_area(db, areaID)

@router.get("/{scheduleID}", dependencies=[Depends(get_current_user)])
def get_schedule(scheduleID: str, db: Session = Depends(get_db)):
    schedule = get_schedule_by_id(db, scheduleID)
    if not schedule:
        raise HTTPException(status_code=404, detail="Schedule not found")
    return schedule

@router.patch("/{scheduleID}/status", dependencies=[Depends(require_role("MunicipalAdmin"))])
def update_status(scheduleID: str, update: OutageScheduleUpdate, db: Session = Depends(get_db)):
    return update_schedule_status(db, scheduleID, update.status)

@router.delete("/{scheduleID}", dependencies=[Depends(require_role("MunicipalAdmin", "ITStaff"))])
def remove_schedule(scheduleID: str, db: Session = Depends(get_db)):
    delete_schedule(db, scheduleID)
    return {"message": "Schedule deleted successfully"}