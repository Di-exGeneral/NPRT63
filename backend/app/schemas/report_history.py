from pydantic import BaseModel
from datetime import datetime

class ReportHistoryResponse(BaseModel):
    historyID: str
    reportID: str
    previousStatus: str
    newStatus: str
    changedBy: str
    changedAt: datetime

    class Config:
        from_attributes = True