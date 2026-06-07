from datetime import datetime
from pydantic import BaseModel, EmailStr, Field
from typing import Optional


# ── Auth ──────────────────────────────────────────────────────────────────────

class UserCreate(BaseModel):
    name: str = Field(min_length=2, max_length=120)
    email: EmailStr
    password: str = Field(min_length=6)


class UserOut(BaseModel):
    id: int
    name: str
    email: str
    created_at: datetime

    model_config = {"from_attributes": True}


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut


class LoginIn(BaseModel):
    email: EmailStr
    password: str


# ── Saved Addresses ───────────────────────────────────────────────────────────

class AddressCreate(BaseModel):
    label: str = Field(min_length=1, max_length=80)
    city_name: str
    uf: str = Field(min_length=2, max_length=2)
    ibge_code: str
    lat: float
    lng: float


class AddressOut(BaseModel):
    id: int
    label: str
    city_name: str
    uf: str
    ibge_code: str
    lat: float
    lng: float
    created_at: datetime

    model_config = {"from_attributes": True}


# ── Alert History ─────────────────────────────────────────────────────────────

class AlertHistoryOut(BaseModel):
    id: int
    city_name: str
    uf: str
    lat: float
    lng: float
    risk_level: str
    severity: str
    rainfall_mm: float
    reason: str
    source: str
    triggered_alert: bool
    recorded_at: datetime

    model_config = {"from_attributes": True}


# ── Risk (resposta principal da API) ─────────────────────────────────────────

class RiskResponse(BaseModel):
    city_name: str
    uf: str
    state_name: str
    ibge_code: str
    lat: float
    lng: float
    rainfall_mm: float
    max_intensity_mm3h: float
    weather_description: str
    weather_source: str
    risk_level: str          # none / low / moderate / high / veryHigh
    risk_message: str
    severity: str            # safe / watch / warning / danger / emergency
    severity_title: str
    should_alert: bool
    reason: str
    color_hex: str           # cor para o Flutter usar diretamente

class AlertStatus(BaseModel):
    region: str
    severity: str
    description: str
    color: str

class EmergencyAction(BaseModel):
    call_number: str
    message: str
