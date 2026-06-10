RISK_THRESHOLDS = {
    "low":      50.0,
    "moderate": 30.0,
    "high":     15.0,
    "veryHigh":  5.0,
}

RISK_MESSAGES = {
    "none":     "Área sem mapeamento de risco",
    "low":      "Risco baixo de deslizamento/enchente",
    "moderate": "Risco moderado — fique atento",
    "high":     "Alto risco — evite áreas de várzea",
    "veryHigh": "Risco crítico — saia da área imediatamente",
}

RISK_COLORS = {
    "none":     "#9E9E9E",
    "low":      "#4CAF50",
    "moderate": "#FFEB3B",
    "high":     "#FF9800",
    "veryHigh": "#F44336",
}

SEVERITY_TITLES = {
    "info":      "Sem informação",
    "safe":      "Seguro",
    "watch":     "Atenção",
    "warning":   "Alerta",
    "danger":    "Perigo",
    "emergency": "Emergência",
}

SEVERITY_COLORS = {
    "info":      "#4CAF50",
    "safe":      "#4CAF50",
    "watch":     "#FFEB3B",
    "warning":   "#FF9800",
    "danger":    "#FF7E7B",
    "emergency": "#B71C1C",
}


def evaluate(risk_level: str, rainfall_mm: float) -> dict:
    if risk_level == "none":
        return {
            "severity": "info",
            "severity_title": SEVERITY_TITLES["info"],
            "should_alert": False,
            "reason": "Área sem dados de risco mapeados pelo CEMADEN.",
            "color_hex": SEVERITY_COLORS["info"],
        }

    severity_map = {
        "low": "watch",
        "moderate": "warning",
        "high": "danger",
        "veryHigh": "emergency",
    }
    severity = severity_map.get(risk_level, "info")

    should_alert = True 

    risk_level_pt = {
        "low": "baixo",
        "moderate": "moderado",
        "high": "alto",
        "veryHigh": "muito alto",
    }

    reason = f"Risco estadual {risk_level_pt.get(risk_level, risk_level)} segundo boletim do CEMADEN."
    return {
        "severity": severity,
        "severity_title": SEVERITY_TITLES[severity],
        "should_alert": should_alert,
        "reason": reason,
        "color_hex": SEVERITY_COLORS[severity],
    }



def _severity_for(risk: str, alert: bool) -> str:
    if not alert:
        return "safe"
    return {
        "low":      "watch",
        "moderate": "warning",
        "high":     "danger",
        "veryHigh": "emergency",
    }.get(risk, "info")


def _label(risk: str) -> str:
    return {
        "low": "baixo", "moderate": "moderado",
        "high": "alto", "veryHigh": "muito alto",
    }.get(risk, risk)