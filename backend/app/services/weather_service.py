import httpx
import os
from dotenv import load_dotenv

load_dotenv()

OPEN_METEO_URL = "https://api.open-meteo.com/v1/forecast"
OW_URL = "https://api.openweathermap.org/data/2.5/forecast"
OW_KEY = os.getenv("OPENWEATHER_API_KEY", "")

WMO_DESC = {
    0: "Céu limpo", 1: "Predominantemente limpo", 2: "Parcialmente nublado",
    3: "Nublado", 45: "Neblina", 48: "Neblina com geada",
    51: "Garoa leve", 53: "Garoa moderada", 55: "Garoa intensa",
    61: "Chuva leve", 63: "Chuva moderada", 65: "Chuva forte",
    71: "Neve leve", 73: "Neve moderada", 75: "Neve intensa",
    80: "Pancadas leves", 81: "Pancadas moderadas", 82: "Pancadas fortes",
    95: "Tempestade", 96: "Tempestade com granizo leve",
    99: "Tempestade com granizo intenso",
}


async def fetch_weather(lat: float, lng: float) -> dict:
    """Tenta Open-Meteo primeiro; cai no OpenWeather se falhar."""
    try:
        return await _open_meteo(lat, lng)
    except Exception as e:
        print(f"[WeatherService] Open-Meteo falhou: {e} — tentando OpenWeather")
        try:
            return await _open_weather(lat, lng)
        except Exception as e2:
            print(f"[WeatherService] OpenWeather também falhou: {e2}")
            return {"rainfall_mm": 0.0, "max_intensity_mm3h": 0.0,
                    "description": "Indisponível", "source": "N/A"}


async def _open_meteo(lat: float, lng: float) -> dict:
    async with httpx.AsyncClient(timeout=20) as client:
        r = await client.get(OPEN_METEO_URL, params={
            "latitude": round(lat, 4),
            "longitude": round(lng, 4),
            "daily": "precipitation_sum,weathercode",
            "hourly": "precipitation",
            "timezone": "America/Sao_Paulo",
            "forecast_days": 2,
        })
        r.raise_for_status()
        data = r.json()

    daily = data.get("daily", {})
    hourly = data.get("hourly", {})

    precip_list = daily.get("precipitation_sum", [0])
    accumulated = float(precip_list[0]) if precip_list else 0.0

    hourly_precip = [float(v) for v in (hourly.get("precipitation") or [])[:24]]
    max_hour = max(hourly_precip, default=0.0)

    code = int((daily.get("weathercode") or [0])[0])
    desc = WMO_DESC.get(code, "Condição não disponível")

    return {
        "rainfall_mm": accumulated,
        "max_intensity_mm3h": max_hour * 3,
        "description": desc,
        "source": "Open-Meteo",
    }


async def _open_weather(lat: float, lng: float) -> dict:
    if not OW_KEY:
        raise ValueError("Chave OpenWeather não configurada")

    async with httpx.AsyncClient(timeout=20) as client:
        r = await client.get(OW_URL, params={
            "lat": lat, "lon": lng, "appid": OW_KEY,
            "units": "metric", "lang": "pt_br", "cnt": 8,
        })
        r.raise_for_status()
        data = r.json()

    items = data.get("list", [])
    total = 0.0
    max3h = 0.0
    for item in items:
        val = float(item.get("rain", {}).get("3h", 0))
        total += val
        if val > max3h:
            max3h = val

    desc = ""
    if items:
        desc = items[0].get("weather", [{}])[0].get("description", "")

    return {
        "rainfall_mm": total,
        "max_intensity_mm3h": max3h,
        "description": desc,
        "source": "OpenWeather",
    }