from fastapi import APIRouter, HTTPException, status
from .schemas import AgendamentoAtualizar, AgendamentoCriar, AgendamentoPublico

router = APIRouter(prefix="/agendamentos", tags=["Agendamentos"])

agendamentos: list[dict] = [
    {
        "id": 1,
        "produtor": "Fazenda Boa Vista",
        "tipo_grao": "Soja",
        "quantidade_toneladas": 45.5,
        "status": "confirmado",
    },
    {
        "id": 2,
        "produtor": "Sítio Santa Maria",
        "tipo_grao": "Milho",
        "quantidade_toneladas": 30.0,
        "status": "pendente",
    },
]


@router.get("/", response_model=list[AgendamentoPublico])
def listar():
    return agendamentos

@router.post(
    "/", response_model=AgendamentoPublico, status_code=status.HTTP_201_CREATED
)
def criar(dados: AgendamentoCriar):
    novo_id = agendamentos[-1]["id"] + 1 if agendamentos else 1
    novo = {"id": novo_id, **dados.model_dump()}
    agendamentos.append(novo)
    return novo


@router.get("/{agendamento_id}", response_model=AgendamentoPublico)
def buscar(agendamento_id: int):
    for item in agendamentos:
        if item["id"] == agendamento_id:
            return item
    raise HTTPException(status_code=404, detail="Agendamento não encontrado")


@router.patch("/{agendamento_id}", response_model=AgendamentoPublico)
def atualizar(agendamento_id: int, dados: AgendamentoAtualizar):
    for item in agendamentos:
        if item["id"] == agendamento_id:
            dados_atualizados = dados.model_dump(exclude_unset=True)
            item.update(dados_atualizados)
            return item
    raise HTTPException(status_code=404, detail="Agendamento não encontrado")


@router.delete("/{agendamento_id}", status_code=status.HTTP_204_NO_CONTENT)
def apagar(agendamento_id: int):
    for item in agendamentos:
        if item["id"] == agendamento_id:
            agendamentos.remove(item)
            return
    raise HTTPException(status_code=404, detail="Agendamento não encontrado")