from fastapi import APIRouter, Depends, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from ..database import get_db
from ..seguranca import obter_usuario_atual
from . import service
from .models import Usuario
from .schemas import Token, UsuarioCreate, UsuarioResponse

router = APIRouter(prefix="/usuarios", tags=["Usuarios"])


@router.post("/", response_model=UsuarioResponse, status_code=status.HTTP_201_CREATED)
def cadastrar_usuario(dados: UsuarioCreate, db: Session = Depends(get_db)):
    return service.criar_usuario(db, dados)


@router.post("/login", response_model=Token)
def fazer_login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
):
    token = service.autenticar_usuario(
        db,
        email=form_data.username,
        senha=form_data.password,
    )
    return {"access_token": token, "token_type": "bearer"}


@router.get("/eu", response_model=UsuarioResponse)
def obter_meu_perfil(usuario_atual: Usuario = Depends(obter_usuario_atual)):
    return usuario_atual