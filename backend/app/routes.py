from fastapi import APIRouter
from app.schemas import AlertStatus, EmergencyAction

router = APIRouter()

@router.get("/alerts", response_model=list[AlertStatus])
def get_alerts():
    return [
        {
            "region": "Zona Leste",
            "severity": "Crítico",
            "description": "Chuvas intensas com risco de alagamento iminente.",
            "color": "#FF7E7B",
        },
        {
            "region": "Centro",
            "severity": "Moderado",
            "description": "Atenção para ruas baixas e áreas ribeirinhas.",
            "color": "#FFAD59",
        },
    ]

@router.get("/status", response_model=AlertStatus)
def get_current_status():
    return {
        "region": "Sua região",
        "severity": "Crítico",
        "description": "Risco de alagamento elevado. Monitore rotas de fuga.",
        "color": "#FF7E7B",
    }

@router.post("/emergency", response_model=EmergencyAction)
def trigger_emergency_call():
    return {
        "call_number": "199",
        "message": "Conectando à Defesa Civil...",
    }
