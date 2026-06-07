import httpx
from typing import Optional

NOMINATIM_URL = "https://nominatim.openstreetmap.org/reverse"
IBGE_URL = "https://servicodados.ibge.gov.br/api/v1/localidades/municipios"

UF_MAP = {
    "São Paulo": "SP", "Rio de Janeiro": "RJ", "Minas Gerais": "MG",
    "Bahia": "BA", "Rio Grande do Sul": "RS", "Paraná": "PR",
    "Santa Catarina": "SC", "Goiás": "GO", "Pernambuco": "PE",
    "Ceará": "CE", "Pará": "PA", "Amazonas": "AM", "Maranhão": "MA",
    "Mato Grosso": "MT", "Mato Grosso do Sul": "MS", "Espírito Santo": "ES",
    "Piauí": "PI", "Alagoas": "AL", "Rio Grande do Norte": "RN",
    "Paraíba": "PB", "Sergipe": "SE", "Rondônia": "RO", "Tocantins": "TO",
    "Acre": "AC", "Amapá": "AP", "Roraima": "RR", "Distrito Federal": "DF",
}


def _normalize(s: str) -> str:
    import unicodedata
    return unicodedata.normalize("NFD", s.lower()).encode("ascii", "ignore").decode()


async def reverse_geocode(lat: float, lng: float) -> dict:
    async with httpx.AsyncClient(timeout=15) as client:
        r = await client.get(
            NOMINATIM_URL,
            params={"lat": lat, "lon": lng, "format": "json",
                    "addressdetails": 1, "accept-language": "pt-BR"},
            headers={"User-Agent": "FloodGuardApp/1.0"},
        )
        r.raise_for_status()
        data = r.json()

    addr = data.get("address", {})
    city = (addr.get("city") or addr.get("town") or
            addr.get("village") or addr.get("municipality") or "")
    state_name = addr.get("state", "")
    uf = UF_MAP.get(state_name, state_name[:2].upper() if len(state_name) >= 2 else "BR")

    return {"city_name": city, "uf": uf, "state_name": state_name}


async def fetch_ibge_code(city_name: str, uf: str) -> str:
    try:
        async with httpx.AsyncClient(timeout=20) as client:
            r = await client.get(f"{IBGE_URL}?orderBy=nome")
            r.raise_for_status()
            items = r.json()

        normalized = _normalize(city_name)
        for item in items:
            nome = item.get("nome", "")
            sigla = (item.get("microrregiao", {})
                         .get("mesorregiao", {})
                         .get("UF", {})
                         .get("sigla", "")).upper()
            if _normalize(nome) == normalized and sigla == uf.upper():
                return str(item["id"])
    except Exception:
        pass
    return ""


async def resolve_location(lat: float, lng: float) -> dict:
    geo = await reverse_geocode(lat, lng)
    ibge_code = await fetch_ibge_code(geo["city_name"], geo["uf"])
    return {**geo, "ibge_code": ibge_code, "lat": lat, "lng": lng}