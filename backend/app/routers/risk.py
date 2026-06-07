from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional

from app.db.database import get_db
from app.models.schemas import RiskResponse
from app.models.db_models import AlertHistory, User
from app.services.location_service import resolve_location
from app.services.weather_service import fetch_weather
from app.services.geo_risk_service import fetch_risk_by_state
from app.services.alert_engine import evaluate, RISK_MESSAGES, RISK_COLORS
from app.api.deps import get_optional_user

router = APIRouter(prefix="/risk", tags=["risk"])


@router.get("", response_model=RiskResponse)
async def get_risk(
    lat: float = Query(..., description="Latitude"),
    lng: float = Query(..., description="Longitude"),
    db: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_optional_user),
):
    # Executa localização e clima em paralelo
    import asyncio
    location_task = resolve_location(lat, lng)
    weather_task = fetch_weather(lat, lng)

    location, weather = await asyncio.gather(location_task, weather_task)

    # Busca risco pelo estado
    risk_level = await fetch_risk_by_state(location["state_name"])

    # Motor de alerta
    alert = evaluate(risk_level, weather["rainfall_mm"])

    response = RiskResponse(
        city_name=location["city_name"],
        uf=location["uf"],
        state_name=location["state_name"],
        ibge_code=location["ibge_code"],
        lat=lat,
        lng=lng,
        rainfall_mm=weather["rainfall_mm"],
        max_intensity_mm3h=weather["max_intensity_mm3h"],
        weather_description=weather["description"],
        weather_source=weather["source"],
        risk_level=risk_level,
        risk_message=RISK_MESSAGES.get(risk_level, ""),
        severity=alert["severity"],
        severity_title=alert["severity_title"],
        should_alert=alert["should_alert"],
        reason=alert["reason"],
        color_hex=alert["color_hex"],
    )

    # Persiste no histórico se usuário autenticado
    if current_user:
        history = AlertHistory(
            user_id=current_user.id,
            city_name=response.city_name,
            uf=response.uf,
            lat=lat,
            lng=lng,
            risk_level=risk_level,
            severity=alert["severity"],
            rainfall_mm=weather["rainfall_mm"],
            reason=alert["reason"],
            source=weather["source"],
            triggered_alert=alert["should_alert"],
        )
        db.add(history)
        await db.commit()

    return response