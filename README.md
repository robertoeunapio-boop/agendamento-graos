Você é um designer de produto criando o protótipo navegável de uma aplicação.

CONTEXTO

Sistema de agendamento de graos. O usuário principal é motoristas de caminhao.

ENTIDADE PRINCIPAL

agendamento, com os campos:

- titulo(texto, obrigatório)

- agendamento(carregamento, descarregamento)

- data(data,obrigatório)

- grao(sorgo, milho, soja)

- caminhao(graneleiro, caçamba)

- horario(intero, obrigatorio)

- observacao(texto, opcional)

Cada registro pertence a um usuário logado — um usuário tem vários agendamentos; cada agendamento tem vários usuários.

TELAS (nesta ordem)

1. Login: e-mail e senha, link para cadastro, área para mensagem de erro.

2. Cadastro de usuário: nome, e-mail e senha, com as regras visíveis.

3. Listagem de agendamento: busca por titulo, data, grao e horario, um botão de criar em destaque, e o

   estado de lista vazia, com mensagem convidando a criar o primeiro registro.

4. Formulário de criar/editar agendamento, com as validações visíveis.

5. Detalhe de um registro, com editar e excluir (excluir pede confirmação).

STACK DE DESTINO — leia com atenção

Este protótipo é descartável, mas ele vira a especificação de um aplicativo

Flutter que consome uma API FastAPI. Projete pensando nisso:

- Use Material Design 3 como linguagem visual.

- Layout em coluna única, pensado primeiro para celular.

- Não use nada que não tenha equivalente direto em Flutter: sem grid CSS

  complexo, sem hover como única forma de revelar informação, sem sticky.

- Todo estado de tela precisa existir e estar desenhado: carregando, vazio,

  erro e sucesso.

RESTRIÇÕES

- Não crie backend, banco de dados nem autenticação real: use dados de

  exemplo fixos, inventados.

- Não invente campos que não estão na lista acima.

- Todos os textos da interface em português do Brasil.

## App (Flutter)

A tela de agendamentos chama `GET /agendamentos/` pelas camadas do app (tela, `AgendamentoService`, `AgendamentoRepository`), com o token no cabeçalho, e mostra só os agendamentos de quem está logado. Ela tem quatro estados: carregando, erro (com Tentar de novo), lista vazia e a lista.

Tocar num agendamento abre o detalhe pela rota `/agendamento`, com o id nos `arguments`: o detalhe busca o agendamento na API (`GET /agendamentos/{id}`), para mostrar o dado de agora.

O app cria, edita e exclui agendamentos pelas camadas (tela, `AgendamentoService`, `AgendamentoRepository`), com o token no cabeçalho: `POST /agendamentos/`, `PUT /agendamentos/{id}` e `DELETE /agendamentos/{id}`. Um formulário só (`FormularioScreen`) serve para criar e para editar.

A validação acontece nas duas pontas: o `validator` de cada campo antes de enviar, e a API, que recusa com 422 ou 409; a frase da API aparece na tela. Excluir pede confirmação num diálogo. Depois de cada operação, a tela fecha com `true`, e a lista pede os agendamentos de novo.