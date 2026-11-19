import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

load_dotenv()

URL = os.environ["DATABASE_URL"]
if URL.startswith("postgres://"):
    URL = URL.replace("postgres://", "postgresql+psycopg://", 1)
elif URL.startswith("postgresql://"):
    URL = URL.replace("postgresql://", "postgresql+psycopg://", 1)

engine = (
    create_engine(URL, connect_args={"check_same_thread": False})
    if "sqlite" in URL
    else create_engine(URL)
)

SessionLocal = sessionmaker(bind=engine, autoflush=False)


class Base(DeclarativeBase):
    """Base para todas as tabelas usarem no SQLAlchemy."""

    pass


def get_db():
    """Injeção de dependência da sessão por requisição."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()