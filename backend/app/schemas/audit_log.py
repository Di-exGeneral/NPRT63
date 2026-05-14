from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class AuditLogResponse(BaseModel):
    logID: str
    userID: str
    action: str
    timestamp: datetime
    details: Optional[str]

    class Config:
        from_attributes = True