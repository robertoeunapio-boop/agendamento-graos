from sqlalchemy.orm import Session
from . import repository
from .erros import (
    AgendamentoBloqueado,
    AgendamentoNaoEncontrado,
    ConflitoDeAgendamento,
)


def listar(
    db: Session,
    dono_id: int,
    produtor: str | None = None,
    tipo_grao: str | None = None,
):
    return repository.listar(
        db, dono_id=dono_id, produtor=produtor, tipo_grao=tipo_grao
    )


def buscar(db: Session, agendamento_id: int, dono_id: int):
    agendamento = repository.buscar_por_id_e_dono(db, agendamento_id, dono_id)
    if agendamento is None:
        raise AgendamentoNaoEncontrado(
            f"Agendamento {agendamento_id} não encontrado."
        )
    return agendamento


def criar(db: Session, dados: dict, dono_id: int):
    existente = repository.buscar_por_produtor_e_grao_e_dono(
        db, produtor=dados["produtor"], tipo_grao=dados["tipo_grao"], dono_id=dono_id
    )
    if existente:
        raise ConflitoDeAgendamento(
            f"O produtor '{dados['produtor']}' já possui um agendamento para '{dados['tipo_grao']}'."
        )

    dados_com_dono = {**dados, "dono_id": dono_id}
    return repository.criar(db, dados_com_dono)


def atualizar(db: Session, agendamento_id: int, mudancas: dict, dono_id: int):
    agendamento = buscar(db, agendamento_id, dono_id=dono_id)
    return repository.atualizar(db, agendamento, mudancas)


def apagar(db: Session, agendamento_id: int, dono_id: int):
    agendamento = buscar(db, agendamento_id, dono_id=dono_id)

    status_bloqueados = ["concluído", "concluido", "em transporte"]
    if agendamento.status.lower() in status_bloqueados:
        raise AgendamentoBloqueado(
            f"Não é permitido apagar agendamento com status '{agendamento.status}'."
        )

    repository.apagar(db, agendamento)