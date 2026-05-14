from pydantic import BaseModel

class AreaCreate(BaseModel):
    areaID: str
    suburbName: str
    municipalityName: str

class AreaResponse(BaseModel):
    areaID: str
    suburbName: str
    municipalityName: str

    class Config:
        from_attributes = True