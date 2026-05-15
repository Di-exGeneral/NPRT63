from sqlalchemy.orm import Session
from app.models.area import Area
from app.schemas.area import AreaCreate
import uuid

def create_area(db: Session, area: AreaCreate) -> Area:
    new_area = Area(
        areaID=str(uuid.uuid4()),
        suburbName=area.suburbName,
        municipalityName=area.municipalityName
    )
    db.add(new_area)
    db.commit()
    db.refresh(new_area)
    return new_area

def get_all_areas(db: Session):
    return db.query(Area).all()

def get_area_by_id(db: Session, areaID: str) -> Area:
    return db.query(Area).filter(Area.areaID == areaID).first()