from datetime import datetime
from sqlalchemy import String, Float, Integer, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.db.database import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(120))
    email: Mapped[str] = mapped_column(String(200), unique=True, index=True)
    hashed_password: Mapped[str] = mapped_column(String(200))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    addresses: Mapped[list["SavedAddress"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
    alert_history: Mapped[list["AlertHistory"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )


class SavedAddress(Base):
    __tablename__ = "saved_addresses"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    label: Mapped[str] = mapped_column(String(80))       # ex: "Casa", "Trabalho"
    city_name: Mapped[str] = mapped_column(String(120))
    uf: Mapped[str] = mapped_column(String(2))
    ibge_code: Mapped[str] = mapped_column(String(10))
    lat: Mapped[float] = mapped_column(Float)
    lng: Mapped[float] = mapped_column(Float)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    user: Mapped["User"] = relationship(back_populates="addresses")


class AlertHistory(Base):
    __tablename__ = "alert_history"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    city_name: Mapped[str] = mapped_column(String(120))
    uf: Mapped[str] = mapped_column(String(2))
    lat: Mapped[float] = mapped_column(Float)
    lng: Mapped[float] = mapped_column(Float)
    risk_level: Mapped[str] = mapped_column(String(20))      # none/low/moderate/high/veryHigh
    severity: Mapped[str] = mapped_column(String(20))        # safe/watch/warning/danger/emergency
    rainfall_mm: Mapped[float] = mapped_column(Float)
    reason: Mapped[str] = mapped_column(Text)
    source: Mapped[str] = mapped_column(String(40))          # OpenWeather / Open-Meteo
    triggered_alert: Mapped[bool] = mapped_column(Boolean)
    recorded_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    user: Mapped["User"] = relationship(back_populates="alert_history")