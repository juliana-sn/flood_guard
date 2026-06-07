import httpx
import unicodedata
from bs4 import BeautifulSoup

CEMADEN_INDEX = (
    "https://www.gov.br/cemaden/pt-br/assuntos/riscos-geo-hidrologicos"
)


def _normalize(s: str) -> str:
    return unicodedata.normalize("NFD", s.lower()).encode("ascii", "ignore").decode()


async def _get_latest_bulletin_url() -> str | None:
    async with httpx.AsyncClient(timeout=20, follow_redirects=True) as client:
        r = await client.get(CEMADEN_INDEX)
        r.raise_for_status()

    soup = BeautifulSoup(r.text, "html.parser")
    for a in soup.find_all("a", href=True):
        href = a["href"]
        if "previsao-de-riscos-geo-hidrologicos" in href:
            if href.startswith("http"):
                return href
            return "https://www.gov.br" + href
    return None


async def fetch_risk_by_state(state_name: str) -> str:
    """
    Retorna: none | low | moderate | high | veryHigh
    """
    try:
        url = await _get_latest_bulletin_url()
        if not url:
            print("[GeoRiskService] Boletim não encontrado")
            return "none"

        async with httpx.AsyncClient(timeout=25, follow_redirects=True) as client:
            r = await client.get(url)
            r.raise_for_status()

        text = _normalize(BeautifulSoup(r.text, "html.parser").get_text(" "))
        state_norm = _normalize(state_name)

        # Procura trecho que menciona o estado seguido de nível de risco
        import re
        pattern = re.compile(
            rf"{re.escape(state_norm)}.{{0,300}}?(muito alto|alto|moderado|baixo)",
            re.DOTALL,
        )
        match = pattern.search(text)
        if not match:
            return "none"

        trecho = match.group(0)
        if "muito alto" in trecho:
            return "veryHigh"
        if "alto" in trecho:
            return "high"
        if "moderado" in trecho:
            return "moderate"
        if "baixo" in trecho:
            return "low"
        return "none"

    except Exception as e:
        print(f"[GeoRiskService] Erro: {e}")
        return "none"