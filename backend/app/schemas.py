from pydantic import BaseModel

class AlertStatus(BaseModel):
    region: str
    severity: str
    description: str
    color: str

class EmergencyAction(BaseModel):
    call_number: str
    message: str
