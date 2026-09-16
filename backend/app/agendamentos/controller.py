from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..seguranca import obter_usuario_atual
from . import service
from .schemas import AgendamentoAtualizar, AgendamentoCriar, AgendamentoPublico

router = APIRouter(
    prefix="/agendamentos",
    tags=["Agendamentos"],
    dependencies=[Depends(obter_usuario_atual)],
)


@router.post("/", response_model=AgendamentoPublico, status_code=status.HTTP_201_CREATED)
def criar_agendamento(dados: AgendamentoCriar, db: Session = Depends(get_db)):
    return service.criar(db, dados.model_dump())


@router.get("/", response_model=list[AgendamentoPublico])
def listar_agendamentos(db: Session = Depends(get_db)):
    return service.listar(db)

@router.get("/{agendamento_id}", response_model=AgendamentoPublico)
def obter_agendamento(agendamento_id: int, db: Session = Depends(get_db)):
    return service.buscar(db, agendamento_id)


@router.put("/{agendamento_id}", response_model=AgendamentoPublico)
def atualizar_agendamento(
    agendamento_id: int,
    dados: AgendamentoAtualizar,
    db: Session = Depends(get_db),
):
    return service.atualizar(db, agendamento_id, dados.model_dump(exclude_unset=True))


@router.delete("/{agendamento_id}", status_code=status.HTTP_204_NO_CONTENT)
def deletar_agendamento(agendamento_id: int, db: Session = Depends(get_db)):
    service.apagar(db, agendamento_id)
    return None