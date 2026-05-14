from pydantic import BaseModel
from datetime import datetime

class PhotoResponse(BaseModel):
    photoID: str
    reportID: str
    photoURL: str
    uploadedAt: datetime

    class Config:
        from_attributes = True