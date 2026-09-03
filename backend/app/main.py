from fastapi import FastAPI
from .agendamentos import controller as agendamentos_controller

app = FastAPI(title="API Agendamento de Grãos", version="0.2.0")

app.include_router(agendamentos_controller.router)


@app.get("/")
def raiz():
    return {"mensagem": "API do Agendamento de Grãos está funcionando!"}