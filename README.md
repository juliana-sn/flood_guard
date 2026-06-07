# Flood Guard 

Projeto inicial para o aplicativo *Flood Guard* com frontend em Flutter e backend em FastAPI.

## Estrutura

- `backend/` - API REST em FastAPI.
- `flutter/` - Aplicativo Flutter com telas iniciais do Flood Guard.
- `design/` - Documento de design de produto e experiência.


## Como rodar o backend

**Pré-requisito:** Docker Desktop instalado.

1. Clone o repositório
2. Renomeie `.env.example` para `.env`
3. Execute:

```bash
docker compose up --build
```

4. API disponível em: http://localhost:8000
5. Documentação interativa: http://localhost:8000/docs

Para parar: `docker compose down`

## Como rodar o frontend

1. Abra `flutter/` no Flutter.
2. Execute: `flutter pub get`
3. Inicie: `flutter run`

