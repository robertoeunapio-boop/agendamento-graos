from sqlalchemy.orm import Session
from .models import AgendamentoModel


def listar(db: Session) -> list[AgendamentoModel]:
    return db.query(AgendamentoModel).all()


def buscar_por_id(db: Session, agendamento_id: int) -> AgendamentoModel | None:
    return (
        db.query(AgendamentoModel)
        .filter(AgendamentoModel.id == agendamento_id)
        .first()
    )


def buscar_por_produtor_e_grao(
    db: Session, produtor: str, tipo_grao: str
) -> AgendamentoModel | None:
    return (
        db.query(AgendamentoModel)
        .filter(
            AgendamentoModel.produtor == produtor,
            AgendamentoModel.tipo_grao == tipo_grao,
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
        setattr(agendamento, chave, valor)
    db.commit()
    db.refresh(agendamento)
    return agendamento


def apagar(db: Session, agendamento: AgendamentoModel) -> None:
    db.delete(agendamento)
    db.commit()