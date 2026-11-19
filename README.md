# Agenda de Grãos

Sistema de agendamento de grãos para motoristas de caminhão e produtores: uma API (FastAPI) e um app web (Flutter). Cada usuário cria conta, entra e gerencia só os seus agendamentos.

## No ar

- O app: https://SEU-APP.onrender.com
- A API: https://SUA-API.onrender.com/docs
- O banco: PostgreSQL no Render

A API dorme depois de 15 minutos sem uso: o primeiro acesso leva cerca de 1 minuto.

## Como rodar na sua máquina

### API (pasta backend/)

1. Crie o arquivo `.env`, que fica fora do Git:

        DATABASE_URL=sqlite:///./agendamentos.db
        SECRET_KEY=uma-frase-longa-que-so-voce-conhece

2. Instale, crie as tabelas e ligue a API:

        poetry install
        poetry run alembic upgrade head
        poetry run uvicorn app.main:app --reload

A documentação fica em http://127.0.0.1:8000/docs.

### App (pasta frontend/)

        flutter pub get
        flutter run -d chrome

## Na nuvem

A API sobe pelo `backend/Dockerfile`, no Render, com as variáveis `DATABASE_URL`, `SECRET_KEY` e `ENDERECO_DO_APP` na tela do serviço. O app é um Static Site, construído com `API_URL`. Nenhum segredo está no Git.

## App (Flutter)

A tela de agendamentos chama `GET /agendamentos/` pelas camadas do app (tela, `AgendamentoService`, `AgendamentoRepository`), com o token no cabeçalho, e mostra só os agendamentos de quem está logado. Ela tem quatro estados: carregando, erro (com Tentar de novo), lista vazia e a lista.

Tocar num agendamento abre o detalhe pela rota `/agendamento`, com o id nos `arguments`: o detalhe busca o agendamento na API (`GET /agendamentos/{id}`), para mostrar o dado de agora.

O app cria, edita e exclui agendamentos pelas camadas (tela, `AgendamentoService`, `AgendamentoRepository`), com o token no cabeçalho: `POST /agendamentos/`, `PUT /agendamentos/{id}` e `DELETE /agendamentos/{id}`. Um formulário só (`FormularioScreen`) serve para criar e para editar.

A validação acontece nas duas pontas: o `validator` de cada campo antes de enviar, e a API, que recusa com 422 ou 409; a frase da API aparece na tela. Excluir pede confirmação num diálogo. Depois de cada operação, a tela fecha com `true`, e a lista pede os agendamentos de novo.

A lista tem busca pelo produtor (`GET /agendamentos/?produtor=`), com o x que limpa o campo, e o filtro Só em transporte (`?status=em transporte`); os dois podem valer juntos. Toda ação que muda dados mostra uma faixa: verde quando deu certo, vermelha quando a API recusou.

## Checklist das funcionalidades mínimas

- [x] Autenticação: login e cadastro; sem sessão, a tela de entrada
- [x] CRUD: o Novo cria, o detalhe edita e exclui
- [x] Relacionamento com o usuário: cada um vê só os seus agendamentos (o dono vem do token)
- [x] Validação nas duas pontas: o validator no app, e o 422/409 da API com a frase
- [x] Busca/filtro: o campo de busca por produtor e o chip Só em transporte, pela API
- [x] Feedback visual: a faixa verde ou vermelha de toda ação

## Testes

Na pasta backend/:

    poetry run pytest

Na pasta frontend/:

    flutter test