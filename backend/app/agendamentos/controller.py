from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..seguranca import obter_usuario_atual
from ..usuarios.models import Usuario
from . import service
from .schemas import AgendamentoAtualizar, AgendamentoCriar, AgendamentoPublico

router = APIRouter(
    prefix="/agendamentos",
    tags=["Agendamentos"],
    dependencies=[Depends(obter_usuario_atual)],
)


@router.post("/", response_model=AgendamentoPublico, status_code=status.HTTP_201_CREATED)
def criar_agendamento(
    dados: AgendamentoCriar,
    db: Session = Depends(get_db),
    usuario_atual: Usuario = Depends(obter_usuario_atual),
):
    return service.criar(db, dados.model_dump(), dono_id=usuario_atual.id)


@router.get("/", response_model=list[AgendamentoPublico])
def listar_agendamentos(
    produtor: str | None = None,
    tipo_grao: str | None = None,
    db: Session = Depends(get_db),
    usuario_atual: Usuario = Depends(obter_usuario_atual),
):
    return service.listar(
        db, dono_id=usuario_atual.id, produtor=produtor, tipo_grao=tipo_grao
    )


@router.get("/{agendamento_id}", response_model=AgendamentoPublico)
def obter_agendamento(
    agendamento_id: int,
    db: Session = Depends(get_db),
    usuario_atual: Usuario = Depends(obter_usuario_atual),
):
    return service.buscar(db, agendamento_id, dono_id=usuario_atual.id)


@router.put("/{agendamento_id}", response_model=AgendamentoPublico)
def atualizar_agendamento(
    agendamento_id: int,
    dados: AgendamentoAtualizar,
    db: Session = Depends(get_db),
    usuario_atual: Usuario = Depends(obter_usuario_atual),
):
    return service.atualizar(
        db, agendamento_id, dados.model_dump(exclude_unset=True), dono_id=usuario_atual.id
    )


@router.delete("/{agendamento_id}", status_code=status.HTTP_204_NO_CONTENT)
def deletar_agendamento(
    agendamento_id: int,
    db: Session = Depends(get_db),
    usuario_atual: Usuario = Depends(obter_usuario_atual),
):
    service.apagar(db, agendamento_id, dono_id=usuario_atual.id)
    return None