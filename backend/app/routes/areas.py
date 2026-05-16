from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.area import AreaCreate
from app.services.area_service import create_area, get_all_areas, get_area_by_id
from app.middleware.auth_middleware import get_current_user, require_role

router = APIRouter()

@router.post("/", dependencies=[Depends(require_role("MunicipalAdmin", "ITStaff"))])
def add_area(area: AreaCreate, db: Session = Depends(get_db)):
    return create_area(db, area)

@router.get("/", dependencies=[Depends(get_current_user)])
def list_areas(db: Session = Depends(get_db)):
    return get_all_areas(db)

@router.get("/{areaID}", dependencies=[Depends(get_current_user)])
def get_area(areaID: str, db: Session = Depends(get_db)):
    area = get_area_by_id(db, areaID)
    if not area:
        raise HTTPException(status_code=404, detail="Area not found")
    return area