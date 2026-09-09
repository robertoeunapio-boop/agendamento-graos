from sqlalchemy import Column, Integer, String
from ..database import Base


class AgendamentoModel(Base):
    """Tabela de agendamentos no banco de dados."""

    __tablename__ = "agendamentos"

    id = Column(Integer, primary_key=True, index=True)
    produtor = Column(String(120), nullable=False)
    tipo_grao = Column(String(80), nullable=False)
    quantidade_toneladas = Column(Integer, nullable=False)
    status = Column(String(50), nullable=False, default="Pendente")