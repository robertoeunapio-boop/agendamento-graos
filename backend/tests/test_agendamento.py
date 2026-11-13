AGENDAMENTO = {
    "produtor": "Fazenda Santa Luzia",
    "tipo_grao": "Soja",
    "quantidade_toneladas": 50,
}


def entrar(cliente, email):
    cliente.post(
        "/usuarios/",
        json={"nome": "Teste", "email": email, "senha": "segredo123"},
    )
    dados = {"username": email, "password": "segredo123"}
    resposta = cliente.post("/usuarios/login", data=dados)
    return {"Authorization": "Bearer " + resposta.json()["access_token"]}


def test_criar_um_agendamento_devolve_201_com_o_produtor(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    resposta = cliente.post("/agendamentos/", json=AGENDAMENTO, headers=ana)
    assert resposta.status_code == 201
    assert resposta.json()["produtor"] == "Fazenda Santa Luzia"


def test_sem_token_a_api_recusa(cliente):
    resposta = cliente.get("/agendamentos/")
    assert resposta.status_code == 401


def test_o_bruno_nao_ve_o_agendamento_da_ana(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    bruno = entrar(cliente, "bruno@ifg.edu.br")
    cliente.post("/agendamentos/", json=AGENDAMENTO, headers=ana)
    lista_da_ana = cliente.get("/agendamentos/", headers=ana).json()
    lista_do_bruno = cliente.get("/agendamentos/", headers=bruno).json()
    assert len(lista_da_ana) == 1
    assert lista_do_bruno == []


def test_editar_muda_a_quantidade(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    criado = cliente.post("/agendamentos/", json=AGENDAMENTO, headers=ana).json()
    mudanca = {"quantidade_toneladas": 55}
    resposta = cliente.put(f"/agendamentos/{criado['id']}", json=mudanca, headers=ana)
    assert resposta.status_code == 200
    assert resposta.json()["quantidade_toneladas"] == 55


def test_excluir_tira_o_agendamento_da_lista(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    criado = cliente.post("/agendamentos/", json=AGENDAMENTO, headers=ana).json()
    resposta = cliente.delete(f"/agendamentos/{criado['id']}", headers=ana)
    assert resposta.status_code == 204
    assert cliente.get("/agendamentos/", headers=ana).json() == []


def test_agendamento_que_nao_existe_devolve_404(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    resposta = cliente.get("/agendamentos/999", headers=ana)
    assert resposta.status_code == 404


def test_o_mesmo_produtor_e_grao_duas_vezes_devolve_409(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    cliente.post("/agendamentos/", json=AGENDAMENTO, headers=ana)
    resposta = cliente.post("/agendamentos/", json=AGENDAMENTO, headers=ana)
    assert resposta.status_code == 409


def test_nao_exclui_agendamento_em_transporte(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    em_transporte = {**AGENDAMENTO, "status": "em transporte"}
    criado = cliente.post("/agendamentos/", json=em_transporte, headers=ana).json()
    resposta = cliente.delete(f"/agendamentos/{criado['id']}", headers=ana)
    assert resposta.status_code == 409


def test_quantidade_zero_devolve_422(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    invalido = {**AGENDAMENTO, "quantidade_toneladas": 0}
    resposta = cliente.post("/agendamentos/", json=invalido, headers=ana)
    assert resposta.status_code == 422


def test_a_busca_devolve_so_o_que_combina(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    cliente.post("/agendamentos/", json=AGENDAMENTO, headers=ana)
    outro = {"produtor": "Sítio Boa Vista", "tipo_grao": "Milho", "quantidade_toneladas": 30}
    cliente.post("/agendamentos/", json=outro, headers=ana)
    resposta = cliente.get("/agendamentos/", params={"produtor": "luzia"}, headers=ana)
    assert len(resposta.json()) == 1
    assert resposta.json()[0]["produtor"] == "Fazenda Santa Luzia"


def test_o_filtro_de_status_devolve_so_o_que_combina(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    cliente.post("/agendamentos/", json=AGENDAMENTO, headers=ana)
    outro = {
        "produtor": "Sítio Boa Vista",
        "tipo_grao": "Milho",
        "quantidade_toneladas": 30,
        "status": "em transporte",
    }
    cliente.post("/agendamentos/", json=outro, headers=ana)
    resposta = cliente.get("/agendamentos/", params={"status": "em transporte"}, headers=ana)
    assert len(resposta.json()) == 1
    assert resposta.json()[0]["produtor"] == "Sítio Boa Vista"


def test_senha_errada_devolve_401(cliente):
    entrar(cliente, "ana@ifg.edu.br")
    dados = {"username": "ana@ifg.edu.br", "password": "senha-errada"}
    resposta = cliente.post("/usuarios/login", data=dados)
    assert resposta.status_code == 401