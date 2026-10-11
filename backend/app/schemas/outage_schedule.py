from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class OutageScheduleCreate(BaseModel):
    scheduleID: str
    areaID: str
    startTime: datetime
    endTime: datetime
    description: Optional[str] = None
    status: str
    createdBy: str

class OutageScheduleUpdate(BaseModel):
    status: str

class OutageScheduleEdit(BaseModel):
    areaID: Optional[str] = None
    startTime: Optional[datetime] = None
    endTime: Optional[datetime] = None
    description: Optional[str] = None
    status: Optional[str] = None

class OutageScheduleResponse(BaseModel):
    scheduleID: str
    areaID: str
    startTime: datetime
    endTime: datetime
    description: Optional[str]
    status: str
    createdBy: str

    class Config:
        from_attributes = True