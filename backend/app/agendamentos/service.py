from sqlalchemy.orm import Session
from . import repository
from .erros import (
    AgendamentoBloqueado,
    AgendamentoNaoEncontrado,
    ConflitoDeAgendamento,
)


def listar(db: Session):
    return repository.listar(db)


def buscar(db: Session, agendamento_id: int):
    agendamento = repository.buscar_por_id(db, agendamento_id)
    if agendamento is None:
        raise AgendamentoNaoEncontrado(
            f"Agendamento {agendamento_id} não encontrado."
        )
    return agendamento


def criar(db: Session, dados: dict):
    existente = repository.buscar_por_produtor_e_grao(
        db, produtor=dados["produtor"], tipo_grao=dados["tipo_grao"]
    )
    if existente:
        raise ConflitoDeAgendamento(
            f"O produtor '{dados['produtor']}' já possui um agendamento para '{dados['tipo_grao']}'."
        )
    return repository.criar(db, dados)


def atualizar(db: Session, agendamento_id: int, mudancas: dict):
    agendamento = buscar(db, agendamento_id)
    return repository.atualizar(db, agendamento, mudancas)


def apagar(db: Session, agendamento_id: int):
    agendamento = buscar(db, agendamento_id)

    status_bloqueados = ["concluído", "concluido", "em transporte"]
    if agendamento.status.lower() in status_bloqueados:
        raise AgendamentoBloqueado(
            f"Não é permitido apagar agendamento com status '{agendamento.status}'."
        )

    repository.apagar(db, agendamento)