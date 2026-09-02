from fastapi import FastAPI

# A instancia da aplicacao. O titulo aparece na pagina /docs.
app = FastAPI(title="API do Meu Projeto", version="0.1.0")


# O decorador diz: "esta funcao atende GET na raiz".
@app.get("/")
def raiz():
    # Devolvemos um dicionario. O FastAPI transforma em JSON sozinho.
    return {"mensagem": "A API do meu projeto esta no ar!"}
