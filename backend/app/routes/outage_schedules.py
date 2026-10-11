from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.outage_schedule import OutageScheduleCreate, OutageScheduleUpdate, OutageScheduleEdit
from app.services.outage_schedule_service import create_outage_schedule, get_all_schedules, get_schedules_by_area, get_schedule_by_id, update_schedule_status, update_schedule, delete_schedule
from app.services.emergency_alert_service import notify_area_residents
from app.services.audit_service import log_action
from app.middleware.auth_middleware import get_current_user, require_role

router = APIRouter()

def _validate_times(start, end):
    if start and end and end <= start:
        raise HTTPException(status_code=400, detail="End time must be after start time")

@router.post("/")
def add_schedule(schedule: OutageScheduleCreate, db: Session = Depends(get_db), current_user: dict = Depends(require_role("MunicipalAdmin"))):
    _validate_times(schedule.startTime, schedule.endTime)
    new_schedule = create_outage_schedule(db, schedule)
    log_action(db, current_user["sub"], "OUTAGE_SCHEDULE_CREATED", f"ScheduleID: {new_schedule.scheduleID}, Area: {schedule.areaID}")
    notify_area_residents(
        db, schedule.areaID, "Planned water outage",
        f"Water outage scheduled for your area from {schedule.startTime:%Y-%m-%d %H:%M} to {schedule.endTime:%Y-%m-%d %H:%M}. {schedule.description or ''}".strip(),
        "outage"
    )
    db.refresh(new_schedule)
    return new_schedule

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

@router.put("/{scheduleID}")
def edit_schedule(scheduleID: str, changes: OutageScheduleEdit, db: Session = Depends(get_db), current_user: dict = Depends(require_role("MunicipalAdmin"))):
    schedule = get_schedule_by_id(db, scheduleID)
    if not schedule:
        raise HTTPException(status_code=404, detail="Schedule not found")
    _validate_times(changes.startTime or schedule.startTime, changes.endTime or schedule.endTime)
    schedule = update_schedule(db, schedule, changes.model_dump(exclude_unset=True))
    log_action(db, current_user["sub"], "OUTAGE_SCHEDULE_UPDATED", f"ScheduleID: {scheduleID}")
    notify_area_residents(
        db, schedule.areaID, "Outage schedule updated",
        f"Water outage for your area updated: {schedule.startTime:%Y-%m-%d %H:%M} to {schedule.endTime:%Y-%m-%d %H:%M} ({schedule.status}).",
        "outage"
    )
    db.refresh(schedule)
    return schedule

@router.patch("/{scheduleID}/status")
def update_status(scheduleID: str, update: OutageScheduleUpdate, db: Session = Depends(get_db), current_user: dict = Depends(require_role("MunicipalAdmin"))):
    schedule = update_schedule_status(db, scheduleID, update.status)
    if not schedule:
        raise HTTPException(status_code=404, detail="Schedule not found")
    log_action(db, current_user["sub"], "OUTAGE_SCHEDULE_STATUS_UPDATED", f"ScheduleID: {scheduleID}, Status: {update.status}")
    notify_area_residents(db, schedule.areaID, "Outage status update", f"Water outage for your area is now {update.status}.", "outage")
    db.refresh(schedule)
    return schedule

@router.delete("/{scheduleID}")
def remove_schedule(scheduleID: str, db: Session = Depends(get_db), current_user: dict = Depends(require_role("MunicipalAdmin", "ITStaff"))):
    delete_schedule(db, scheduleID)
    log_action(db, current_user["sub"], "OUTAGE_SCHEDULE_DELETED", f"ScheduleID: {scheduleID}")
    return {"message": "Schedule deleted successfully"}
