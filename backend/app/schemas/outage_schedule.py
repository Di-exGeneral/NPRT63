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