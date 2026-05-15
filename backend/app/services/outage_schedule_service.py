from sqlalchemy.orm import Session
from app.models.outage_schedule import OutageSchedule
from app.schemas.outage_schedule import OutageScheduleCreate
import uuid

def create_outage_schedule(db: Session, schedule: OutageScheduleCreate) -> OutageSchedule:
    new_schedule = OutageSchedule(
        scheduleID=str(uuid.uuid4()),
        areaID=schedule.areaID,
        startTime=schedule.startTime,
        endTime=schedule.endTime,
        description=schedule.description,
        status="Scheduled",
        createdBy=schedule.createdBy
    )
    db.add(new_schedule)
    db.commit()
    db.refresh(new_schedule)
    return new_schedule

def get_all_schedules(db: Session):
    return db.query(OutageSchedule).all()

def get_schedules_by_area(db: Session, areaID: str):
    return db.query(OutageSchedule).filter(OutageSchedule.areaID == areaID).all()

def get_schedule_by_id(db: Session, scheduleID: str) -> OutageSchedule:
    return db.query(OutageSchedule).filter(OutageSchedule.scheduleID == scheduleID).first()

def update_schedule_status(db: Session, scheduleID: str, status: str) -> OutageSchedule:
    schedule = db.query(OutageSchedule).filter(OutageSchedule.scheduleID == scheduleID).first()
    if schedule:
        schedule.status = status
        db.commit()
        db.refresh(schedule)
    return schedule

def delete_schedule(db: Session, scheduleID: str):
    schedule = db.query(OutageSchedule).filter(OutageSchedule.scheduleID == scheduleID).first()
    if schedule:
        db.delete(schedule)
        db.commit()