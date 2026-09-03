from fastapi import FastAPI

app = FastAPI(title="API do Meu Projeto", version="0.1.0")

@app.get("/")
def raiz():
    return {"mensagem": "A API do meu projeto esta no ar!"}

@app.get("/agendamentos")
def listar_agendamentos():
    return [
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