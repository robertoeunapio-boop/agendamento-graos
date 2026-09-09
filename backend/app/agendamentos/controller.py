from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from ..database import get_db
from . import service
from .schemas import AgendamentoAtualizar, AgendamentoCriar, AgendamentoPublico

router = APIRouter(prefix="/agendamentos", tags=["Agendamentos"])


@router.get("/", response_model=list[AgendamentoPublico])
def listar(db: Session = Depends(get_db)):
    return service.listar(db)


@router.post(
    "/", response_model=AgendamentoPublico, status_code=status.HTTP_201_CREATED
)
def criar(dados: AgendamentoCriar, db: Session = Depends(get_db)):
    return service.criar(db, dados.model_dump())


@router.get("/{agendamento_id}", response_model=AgendamentoPublico)
def buscar(agendamento_id: int, db: Session = Depends(get_db)):
    return service.buscar(db, agendamento_id)


@router.patch("/{agendamento_id}", response_model=AgendamentoPublico)
def atualizar(
    agendamento_id: int,
    dados: AgendamentoAtualizar,
    db: Session = Depends(get_db),
):
    return service.atualizar(
        db, agendamento_id, dados.model_dump(exclude_unset=True)
    )


@router.delete("/{agendamento_id}", status_code=status.HTTP_204_NO_CONTENT)
def apagar(agendamento_id: int, db: Session = Depends(get_db)):
    service.apagar(db, agendamento_id)