from pydantic import BaseModel

class ResidentCreate(BaseModel):
    residentID: str
    userID: str
    areaID: str

class ResidentResponse(BaseModel):
    residentID: str
    userID: str
    areaID: str

    class Config:
        from_attributes = True