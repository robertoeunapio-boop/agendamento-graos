from pydantic import BaseModel, Field

class AgendamentoCriar(BaseModel):
    produtor: str = Field(min_length=2, example="Fazenda Santa Luzia")
    tipo_grao: str = Field(min_length=2, example="Soja")
    quantidade_toneladas: float = Field(gt=0, example=45.5)
    status: str = Field(default="pendente", example="pendente")

class AgendamentoPublico(BaseModel):
    id: int
    produtor: str
    tipo_grao: str
    quantidade_toneladas: float
    status: str

class AgendamentoAtualizar(BaseModel):
    produtor: str | None = None
    tipo_grao: str | None = None
    quantidade_toneladas: float | None = Field(default=None, gt=0)
    status: str | None = None