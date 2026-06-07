from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes import router as core_router
from app.routers import auth, addresses, history, risk

app = FastAPI(
    title="Flood Guard API",
    description="API de monitoramento de risco para o Flood Guard.",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Incluindo todos os routers
app.include_router(core_router, prefix="/api")
app.include_router(auth.router, prefix="/api")
app.include_router(addresses.router, prefix="/api")
app.include_router(history.router, prefix="/api")
app.include_router(risk.router, prefix="/api")

@app.get("/health")
def health_check():
    return {"status": "ok", "service": "Flood Guard API"}
