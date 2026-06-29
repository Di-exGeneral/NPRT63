from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class FaultReportCreate(BaseModel):
    title: str
    reportID: str
    residentID: str
    areaID: str
    description: str
    location: str

class FaultReportUpdate(BaseModel):
    status: str

class FaultReportResponse(BaseModel):
    title: str
    reportID: str
    residentID: str
    areaID: str
    description: str
    status: str
    location: str
    timestamp: datetime

    class Config:
        from_attributes = True
