import os

os.environ["DATABASE_URL"] = "sqlite:///./teste.db"
os.environ["SECRET_KEY"] = "uma-chave-so-para-os-testes-com-mais-de-32-letras"

import pytest
from fastapi.testclient import TestClient

from app.database import Base, engine
from app.main import app


@pytest.fixture
def cliente():
    Base.metadata.create_all(engine)
    yield TestClient(app)
    Base.metadata.drop_all(engine)