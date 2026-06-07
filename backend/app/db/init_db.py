import asyncio
from app.db.database import engine, Base
from app.models import db_models

async def init():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    print("Tabelas criadas com sucesso!")

if __name__ == "__main__":
    asyncio.run(init())
