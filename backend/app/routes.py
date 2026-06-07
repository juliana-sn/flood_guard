import json
from pathlib import Path

from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse

from app.models.schemas import AlertStatus, EmergencyAction

router = APIRouter()

POSSIBLE_DATA_DIRS = [
    Path(__file__).resolve().parent.parent / "data",
    Path(__file__).resolve().parent / "data",
]

GEOJSON_FILE = None
for directory in POSSIBLE_DATA_DIRS:
    candidate = directory / "inpe_flood_zones.geojson"
    if candidate.exists():
        GEOJSON_FILE = candidate
        break

if GEOJSON_FILE is None:
    GEOJSON_FILE = POSSIBLE_DATA_DIRS[0] / "inpe_flood_zones.geojson"

def _point_in_ring(point: tuple[float, float], ring: list[list[float]]) -> bool:
    x, y = point
    inside = False
    for i in range(len(ring)):
        x1, y1 = ring[i]
        x2, y2 = ring[(i + 1) % len(ring)]
        intersects = ((y1 > y) != (y2 > y)) and (
            x < (x2 - x1) * (y - y1) / (y2 - y1) + x1
        )
        if intersects:
            inside = not inside
    return inside


def _point_in_polygon(point: tuple[float, float], polygon: list[list[list[float]]]) -> bool:
    if not polygon:
        return False
    if not _point_in_ring(point, polygon[0]):
        return False
    for hole in polygon[1:]:
        if _point_in_ring(point, hole):
            return False
    return True


def _point_in_feature(point: tuple[float, float], feature: dict) -> bool:
    geometry = feature.get("geometry", {})
    geometry_type = geometry.get("type")
    coordinates = geometry.get("coordinates", [])
    if geometry_type == "Polygon":
        return _point_in_polygon(point, coordinates)
    if geometry_type == "MultiPolygon":
        for polygon in coordinates:
            if _point_in_polygon(point, polygon):
                return True
    return False


@router.get("/geojson/flood-zones")
def get_flood_zones_geojson():
    if not GEOJSON_FILE.exists():
        raise HTTPException(status_code=404, detail=f"GeoJSON não encontrado em {GEOJSON_FILE}")
    with open(GEOJSON_FILE, "r", encoding="utf-8") as f:
        geojson = json.load(f)
    return JSONResponse(content=geojson)


@router.get("/alerts/nearby", response_model=AlertStatus)
def get_nearby_alert(lat: float, lon: float):
    if not GEOJSON_FILE.exists():
        raise HTTPException(status_code=404, detail=f"GeoJSON não encontrado em {GEOJSON_FILE}")
    with open(GEOJSON_FILE, "r", encoding="utf-8") as f:
        geojson = json.load(f)

    point = (lon, lat)
    for feature in geojson.get("features", []):
        if _point_in_feature(point, feature):
            properties = feature.get("properties", {})
            severity = properties.get("severity") or properties.get("nivel") or "Crítico"
            description = (
                properties.get("description")
                or properties.get("descricao")
                or "Sua posição atual está dentro de uma área identificada como de risco de inundação."
            )
            color = properties.get("color") or properties.get("cor") or "#FF7E7B"
            return {
                "region": properties.get("region") or properties.get("regiao") or "Sua região",
                "severity": severity,
                "description": description,
                "color": color,
            }

    return {
        "region": "Sua região",
        "severity": "Seguro",
        "description": "Sua posição atual não está dentro de uma área de risco de inundação mapeada.",
        "color": "#2BE66F",
    }


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
