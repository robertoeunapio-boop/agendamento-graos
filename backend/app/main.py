from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from .agendamentos import controller as agendamentos_controller
from .agendamentos.erros import (
    AgendamentoBloqueado,
    AgendamentoNaoEncontrado,
    ConflitoDeAgendamento,
    ErroDeAgendamento,
)
from .database import Base, engine

Base.metadata.create_all(bind=engine)

app = FastAPI(title="API Agendamento de Grãos", version="0.6.0")

app.include_router(agendamentos_controller.router)


@app.get("/")
def raiz():
    return {"mensagem": "API do Agendamento de Grãos está funcionando!"}


@app.exception_handler(ErroDeAgendamento)
def traduzir_recusas_de_negocio(request: Request, erro: ErroDeAgendamento):
    """Traduz as exceções do service.py em respostas HTTP apropriadas."""
    if isinstance(erro, AgendamentoNaoEncontrado):
        status_code = 404
    elif isinstance(erro, (ConflitoDeAgendamento, AgendamentoBloqueado)):
        status_code = 409
    else:
        status_code = 400

    return JSONResponse(status_code=status_code, content={"detail": str(erro)})