from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.area import AreaCreate
from app.services.area_service import create_area, get_all_areas, get_area_by_id
from app.services.audit_service import log_action
from app.middleware.auth_middleware import get_current_user, require_role

router = APIRouter()

@router.post("/")
def add_area(area: AreaCreate, db: Session = Depends(get_db), current_user: dict = Depends(require_role("MunicipalAdmin", "ITStaff"))):
    new_area = create_area(db, area)
    log_action(db, current_user["sub"], "AREA_CREATED", f"AreaID: {area.areaID}, Suburb: {area.suburbName}")
    return new_area

@router.get("/")
def list_areas(db: Session = Depends(get_db)):
    return get_all_areas(db)

@router.get("/{areaID}")
def get_area(areaID: str, db: Session = Depends(get_db)):
    area = get_area_by_id(db, areaID)
    if not area:
        raise HTTPException(status_code=404, detail="Area not found")
    return area

@router.patch("/me/area")
def update_my_area(data: dict, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    from app.models.resident import Resident
    resident = db.query(Resident).filter(Resident.userID == current_user["sub"]).first()
    if not resident:
        raise HTTPException(status_code=404, detail="Resident not found")
    resident.areaID = data.get("areaID")
    db.commit()
    db.refresh(resident)
    return resident
