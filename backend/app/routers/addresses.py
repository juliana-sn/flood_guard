from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.db.database import get_db
from app.models.db_models import SavedAddress, User
from app.models.schemas import AddressCreate, AddressOut
from app.api.deps import get_current_user

router = APIRouter(prefix="/addresses", tags=["addresses"])


@router.get("", response_model=list[AddressOut])
async def list_addresses(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(SavedAddress)
        .where(SavedAddress.user_id == current_user.id)
        .order_by(SavedAddress.created_at.desc())
    )
    return result.scalars().all()


@router.post("", response_model=AddressOut, status_code=201)
async def create_address(
    data: AddressCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    address = SavedAddress(user_id=current_user.id, **data.model_dump())
    db.add(address)
    await db.commit()
    await db.refresh(address)
    return address


@router.delete("/{address_id}", status_code=204)
async def delete_address(
    address_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(SavedAddress).where(
            SavedAddress.id == address_id,
            SavedAddress.user_id == current_user.id,
        )
    )
    address = result.scalar_one_or_none()
    if not address:
        raise HTTPException(status_code=404, detail="Endereço não encontrado")
    await db.delete(address)
    await db.commit()