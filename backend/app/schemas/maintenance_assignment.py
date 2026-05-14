from pydantic import BaseModel
from datetime import datetime

class MaintenanceAssignmentCreate(BaseModel):
    assignmentID: str
    reportID: str
    teamID: str
    assignedBy: str

class MaintenanceAssignmentResponse(BaseModel):
    assignmentID: str
    reportID: str
    teamID: str
    assignedBy: str
    assignedAt: datetime

    class Config:
        from_attributes = True