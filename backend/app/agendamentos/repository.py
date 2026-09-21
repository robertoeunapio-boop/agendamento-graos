from sqlalchemy.orm import Session
from .models import AgendamentoModel


def listar(
    db: Session,
    dono_id: int,
    produtor: str | None = None,
    tipo_grao: str | None = None,
) -> list[AgendamentoModel]:
    query = db.query(AgendamentoModel).filter(AgendamentoModel.dono_id == dono_id)

    if produtor:
        query = query.filter(AgendamentoModel.produtor.ilike(f"%{produtor}%"))
    if tipo_grao:
        query = query.filter(AgendamentoModel.tipo_grao.ilike(f"%{tipo_grao}%"))

    return query.all()


def buscar_por_id_e_dono(
    db: Session, agendamento_id: int, dono_id: int
) -> AgendamentoModel | None:
    return (
        db.query(AgendamentoModel)
        .filter(AgendamentoModel.id == agendamento_id, AgendamentoModel.dono_id == dono_id)
        .first()
    )


def buscar_por_produtor_e_grao_e_dono(
    db: Session, produtor: str, tipo_grao: str, dono_id: int
) -> AgendamentoModel | None:
    return (
        db.query(AgendamentoModel)
        .filter(
            AgendamentoModel.produtor == produtor,
            AgendamentoModel.tipo_grao == tipo_grao,
            AgendamentoModel.dono_id == dono_id,
        )
        .first()
    )


def criar(db: Session, dados: dict) -> AgendamentoModel:
    agendamento = AgendamentoModel(**dados)
    db.add(agendamento)
    db.commit()
    db.refresh(agendamento)
    return agendamento


def atualizar(
    db: Session, agendamento: AgendamentoModel, mudancas: dict
) -> AgendamentoModel:
    for chave, valor in mudancas.items():
        if valor is not None:
            setattr(agendamento, chave, valor)
    db.commit()
    db.refresh(agendamento)
    return agendamento


def apagar(db: Session, agendamento: AgendamentoModel) -> None:
    db.delete(agendamento)
    db.commit()