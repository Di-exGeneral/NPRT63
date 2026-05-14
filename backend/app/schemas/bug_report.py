from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class BugReportCreate(BaseModel):
    title: str
    description: str

class BugReportUpdate(BaseModel):
    status: str
    managedBy: Optional[str] = None

class BugReportResponse(BaseModel):
    bugID: str
    userID: str
    managedBy: Optional[str]
    title: str
    description: str
    screenshot: Optional[str]
    status: str
    submittedAt: datetime
    resolvedAt: Optional[datetime]

    class Config:
        from_attributes = True