from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from .agendamentos.controller import router as agendamentos_router
from .usuarios import erros as usuarios_erros
from .usuarios.controller import router as usuarios_router

app = FastAPI(title="API Agendamento de Grãos")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(agendamentos_router)
app.include_router(usuarios_router)


@app.exception_handler(usuarios_erros.EmailJaCadastradoError)
def email_ja_cadastrado_handler(request: Request, exc: usuarios_erros.EmailJaCadastradoError):
    return JSONResponse(
        status_code=status.HTTP_409_CONFLICT,
        content={"detail": "E-mail já cadastrado"},
    )


@app.exception_handler(usuarios_erros.CredenciaisInvalidasError)
def credenciais_invalidas_handler(request: Request, exc: usuarios_erros.CredenciaisInvalidasError):
    return JSONResponse(
        status_code=status.HTTP_401_UNAUTHORIZED,
        content={"detail": "E-mail ou senha incorretos"},
        headers={"WWW-Authenticate": "Bearer"},
    )