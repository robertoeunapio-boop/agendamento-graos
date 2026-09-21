from pydantic import BaseModel, ConfigDict, Field, field_validator


def _validar_texto_minimo(texto: str, nome_campo: str) -> str:
    texto_limpo = texto.strip()
    if len(texto_limpo) < 2:
        raise ValueError(f"O {nome_campo} precisa ter pelo menos 2 caracteres")
    return texto_limpo


class AgendamentoCriar(BaseModel):
    produtor: str = Field(example="Fazenda Santa Luzia")
    tipo_grao: str = Field(example="Soja")
    quantidade_toneladas: float = Field(gt=0, example=45.5)
    status: str = Field(default="pendente", example="pendente")

    @field_validator("produtor")
    @classmethod
    def validar_produtor(cls, v: str) -> str:
        return _validar_texto_minimo(v, "nome do produtor")

    @field_validator("tipo_grao")
    @classmethod
    def validar_tipo_grao(cls, v: str) -> str:
        return _validar_texto_minimo(v, "tipo de grão")


class AgendamentoPublico(BaseModel):
    id: int
    produtor: str
    tipo_grao: str
    quantidade_toneladas: float
    status: str
    dono_id: int | None = None  

    model_config = ConfigDict(from_attributes=True)


class AgendamentoAtualizar(BaseModel):
    produtor: str | None = None
    tipo_grao: str | None = None
    quantidade_toneladas: float | None = Field(default=None, gt=0)
    status: str | None = None

    @field_validator("produtor")
    @classmethod
    def validar_produtor(cls, v: str | None) -> str | None:
        if v is not None:
            return _validar_texto_minimo(v, "nome do produtor")
        return v

    @field_validator("tipo_grao")
    @classmethod
    def validar_tipo_grao(cls, v: str | None) -> str | None:
        if v is not None:
            return _validar_texto_minimo(v, "tipo de grão")
        return v