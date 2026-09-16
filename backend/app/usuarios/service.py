from sqlalchemy.orm import Session
from ..seguranca import conferir_senha, criar_token_acesso, gerar_hash
from . import erros, repository
from .models import Usuario
from .schemas import UsuarioCreate


def criar_usuario(db: Session, dados: UsuarioCreate) -> Usuario:
    if repository.obter_por_email(db, dados.email):
        raise erros.EmailJaCadastradoError()

    senha_hash = gerar_hash(dados.senha)
    novo_usuario = Usuario(
        nome=dados.nome,
        email=dados.email,
        senha_hash=senha_hash,
    )

    return repository.salvar(db, novo_usuario)


def autenticar_usuario(db: Session, email: str, senha: str) -> str:
    usuario = repository.obter_por_email(db, email)
    if not usuario:
        raise erros.CredenciaisInvalidasError()

    if not conferir_senha(senha, usuario.senha_hash):
        raise erros.CredenciaisInvalidasError()

    return criar_token_acesso(usuario.id)