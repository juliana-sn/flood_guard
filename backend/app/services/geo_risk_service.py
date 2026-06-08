import httpx
import re
import unicodedata
from bs4 import BeautifulSoup

CEMADEN_INDEX = "https://www.gov.br/cemaden/pt-br/assuntos/riscos-geo-hidrologicos"

# Todos os estados + siglas para delimitar trechos
ESTADOS = [
    "acre", "alagoas", "amapa", "amazonas", "bahia", "ceara",
    "distrito federal", "espirito santo", "goias", "maranhao",
    "mato grosso do sul", "mato grosso", "minas gerais", "para",
    "paraiba", "parana", "pernambuco", "piaui", "rio de janeiro",
    "rio grande do norte", "rio grande do sul", "rondonia",
    "roraima", "santa catarina", "sao paulo", "sergipe", "tocantins",
]

SIGLAS = [
    "ac", "al", "ap", "am", "ba", "ce", "df", "es", "go", "ma",
    "mt", "ms", "mg", "pa", "pb", "pr", "pe", "pi", "rj", "rn",
    "rs", "ro", "rr", "sc", "sp", "se", "to",
]

# Palavras-chave de nível — maiúsculas como aparecem no boletim real
NIVEL_PATTERN = re.compile(
    r'\b(muito alta?|alta?|moderada?|baixa?)\b',
    re.IGNORECASE,
)


def _normalize(s: str) -> str:
    return unicodedata.normalize("NFD", s.lower()).encode("ascii", "ignore").decode()


def _nivel_para_risk(nivel: str) -> str:
    n = _normalize(nivel)
    if "muito alt" in n:
        return "veryHigh"
    if "alt" in n:
        return "high"
    if "moderad" in n:
        return "moderate"
    if "baix" in n:
        return "low"
    return "none"


def _extrair_trechos_do_estado(texto_normalizado: str, state_norm: str, uf_norm: str) -> list[str]:
    """
    Retorna lista de trechos onde o estado é mencionado.
    Cada trecho vai da menção até o próximo estado ou até 600 chars.
    """
    # Padrão que aceita tanto o nome completo quanto a sigla entre parênteses
    # Ex: "pernambuco", "(pe)", "pe,"
    patterns = [
        rf'\b{re.escape(state_norm)}\b',
        rf'\({re.escape(uf_norm)}\)',
        rf'\b{re.escape(uf_norm)}\b(?!\w)',  # sigla como palavra isolada
    ]

    todos_estados_pattern = re.compile(
        r'\b(' + '|'.join(re.escape(e) for e in ESTADOS) + r')\b'
        + r'|'
        + r'\b(' + '|'.join(re.escape(s) for s in SIGLAS) + r')\b',
        re.IGNORECASE,
    )

    trechos = []
    for pat in patterns:
        for m in re.finditer(pat, texto_normalizado):
            start = m.start()
            candidato = texto_normalizado[start: start + 600]

            # Corta no próximo estado diferente do atual
            for outro in todos_estados_pattern.finditer(candidato[len(state_norm) + 1:]):
                palavra = outro.group(0)
                if _normalize(palavra) not in (state_norm, uf_norm):
                    candidato = candidato[:len(state_norm) + 1 + outro.start()]
                    break

            trechos.append(candidato)

    return trechos


async def _get_bulletin_text() -> str | None:
    """Busca o texto do boletim mais recente do CEMADEN."""
    try:
        async with httpx.AsyncClient(timeout=25, follow_redirects=True) as client:
            # Primeiro tenta encontrar link direto do boletim na página índice
            r = await client.get(CEMADEN_INDEX)
            r.raise_for_status()
            soup = BeautifulSoup(r.text, "html.parser")

            bulletin_url = None
            for a in soup.find_all("a", href=True):
                href = a["href"]
                if "previsao-de-riscos-geo-hidrologicos" in href:
                    bulletin_url = href if href.startswith("http") else "https://www.gov.br" + href
                    break

            # Se achou link do boletim, busca o conteúdo
            if bulletin_url:
                r2 = await client.get(bulletin_url)
                r2.raise_for_status()
                return BeautifulSoup(r2.text, "html.parser").get_text(" ")

            # Fallback: usa o próprio texto da página índice
            return soup.get_text(" ")

    except Exception as e:
        print(f"[GeoRiskService] Erro ao buscar boletim: {e}")
        return None


async def fetch_risk_by_state(state_name: str, uf: str) -> str:
    """
    Retorna: none | low | moderate | high | veryHigh

    Estratégia robusta para o formato real do boletim CEMADEN:
    1. Busca TODAS as ocorrências do estado (nome e sigla) no texto
    2. Para cada ocorrência, extrai o trecho até o próximo estado
    3. Dentro de cada trecho, procura palavras-chave de nível
    4. Retorna o maior nível encontrado entre todas as ocorrências
    """
    text = await _get_bulletin_text()
    if not text:
        print(f"[GeoRiskService] Boletim não obtido")
        return "none"

    text_norm = _normalize(text)
    state_norm = _normalize(state_name)
    uf_norm    = uf.lower()

    trechos = _extrair_trechos_do_estado(text_norm, state_norm, uf_norm)

    if not trechos:
        print(f"[GeoRiskService] Estado '{state_name}' ({uf}) não encontrado no boletim")
        return "none"

    print(f"[GeoRiskService] {len(trechos)} trecho(s) encontrado(s) para {state_name}/{uf}")

    # Hierarquia de níveis — retorna o maior encontrado
    HIERARQUIA = ["veryHigh", "high", "moderate", "low", "none"]
    maior = "none"

    for i, trecho in enumerate(trechos):
        print(f"[GeoRiskService] Trecho {i+1}: {repr(trecho[:120])}")
        match = NIVEL_PATTERN.search(trecho)
        if match:
            nivel = _nivel_para_risk(match.group(0))
            print(f"[GeoRiskService] Nível encontrado no trecho {i+1}: {nivel} ({match.group(0)})")
            if HIERARQUIA.index(nivel) < HIERARQUIA.index(maior):
                maior = nivel

    return maior