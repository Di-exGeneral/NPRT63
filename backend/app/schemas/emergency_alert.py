from pydantic import BaseModel, Field
from typing import List, Optional

class EmergencyAlertCreate(BaseModel):
    areaID: str
    alertType: str = Field(min_length=1, max_length=100)
    message: str = Field(min_length=1, max_length=500)
    estimatedDuration: Optional[str] = None
    channels: List[str] = ["push", "sms"]
