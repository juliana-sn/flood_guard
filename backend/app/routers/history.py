from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete

from app.db.database import get_db
from app.models.db_models import AlertHistory, User
from app.models.schemas import AlertHistoryOut
from app.api.deps import get_current_user

router = APIRouter(prefix="/history", tags=["history"])


@router.get("", response_model=list[AlertHistoryOut])
async def get_history(
    limit: int = Query(default=50, le=200),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(AlertHistory)
        .where(AlertHistory.user_id == current_user.id)
        .order_by(AlertHistory.recorded_at.desc())
        .limit(limit)
    )
    return result.scalars().all()


@router.delete("", status_code=204)
async def clear_history(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    await db.execute(
        delete(AlertHistory).where(AlertHistory.user_id == current_user.id)
    )
    await db.commit()