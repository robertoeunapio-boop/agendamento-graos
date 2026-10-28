import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/agendamento.dart';
import 'package:frontend/repositories/agendamento_repository.dart';
import 'package:frontend/repositories/usuario_repository.dart';
import 'package:frontend/routes.dart';
import 'package:frontend/screens/agendamento_screen.dart';
import 'package:frontend/screens/agendamentos_screen.dart';
import 'package:frontend/screens/formulario_screen.dart';
import 'package:frontend/screens/inicio_screen.dart';
import 'package:frontend/services/agendamento_service.dart';
import 'package:frontend/services/sessao_service.dart';

const doisAgendamentos = [
  {
    'id': 1,
    'produtor': 'Fazenda Santa Luzia',
    'tipo_grao': 'Soja',
    'quantidade_toneladas': 50.0,
    'status': 'pendente',
    'dono_id': 1,
  },
  {
    'id': 2,
    'produtor': 'Sítio Boa Vista',
    'tipo_grao': 'Milho',
    'quantidade_toneladas': 30.0,
    'status': 'confirmado',
    'dono_id': 1,
  },
];

int pedidos = 0;

SessaoService sessaoDeMentira({Map<String, Object> guardado = const {}}) {
  SharedPreferences.setMockInitialValues(guardado);
  final contas = {
    'ana@biblioteca.com': {'nome': 'Ana', 'senha': 'segredo123'},
  };
  final cliente = MockClient((pedido) async {
    pedidos++;
    if (pedido.url.path == '/usuarios/login') {
      final email = pedido.bodyFields['username'];
      if (contas[email]?['senha'] == pedido.bodyFields['password']) {
        return http.Response(
          jsonEncode({'access_token': 'token-de-$email', 'token_type': 'bearer'}),
          200,
        );
      }
      return http.Response('{"detail": "E-mail ou senha incorretos"}', 401);
    }
    if (pedido.url.path == '/usuarios/eu') {
      final email = (pedido.headers['Authorization'] ?? '').replaceFirst('Bearer token-de-', '');
      if (contas.containsKey(email)) {
        return http.Response(
          jsonEncode({'id': 1, 'nome': contas[email]!['nome'], 'email': email}),
          200,
        );
      }
    }
    return http.Response('{"detail": "Token invalido ou vencido"}', 401);
  });
  return SessaoService(UsuarioRepository(cliente: cliente));
}

http.Client agendamentosDeMentira() {
  return MockClient((pedido) async {
    pedidos++;
    final segmentos = pedido.url.pathSegments.where((s) => s.isNotEmpty).toList();
    final id = segmentos.length > 1 ? int.tryParse(segmentos.last) : null;

    if (id != null) {
      for (final item in doisAgendamentos) {
        if (item['id'] == id) {
          return http.Response(jsonEncode(item), 200);
        }
      }
      return http.Response('{"detail": "Agendamento não encontrado"}', 404);
    }

    return http.Response(jsonEncode(doisAgendamentos), 200);
  });
}

http.Client acervoDeMentira() {
  final List<Map<String, dynamic>> acervo = [
    {
      'id': 1,
      'produtor': 'Fazenda Santa Luzia',
      'tipo_grao': 'Soja',
      'quantidade_toneladas': 50.0,
      'status': 'pendente',
      'dono_id': 1,
    },
    {
      'id': 2,
      'produtor': 'Sítio Boa Vista',
      'tipo_grao': 'Milho',
      'quantidade_toneladas': 30.0,
      'status': 'em transporte',
      'dono_id': 1,
    },
  ];
  const bloqueados = ['concluído', 'concluido', 'em transporte'];

  return MockClient((pedido) async {
    pedidos++;
    final id = int.tryParse(pedido.url.pathSegments.last);

    if (pedido.method == 'POST') {
      final dados = jsonDecode(pedido.body);
      for (final item in acervo) {
        if (item['produtor'] == dados['produtor'] && item['tipo_grao'] == dados['tipo_grao']) {
          return http.Response(
            jsonEncode({
              'detail':
                  "O produtor '${dados['produtor']}' já possui um agendamento para '${dados['tipo_grao']}'.",
            }),
            409,
          );
        }
      }
      final novo = {
        'id': 3,
        'produtor': dados['produtor'],
        'tipo_grao': dados['tipo_grao'],
        'quantidade_toneladas': (dados['quantidade_toneladas'] as num).toDouble(),
        'status': dados['status'],
        'dono_id': 1,
      };
      acervo.add(novo);
      return http.Response(jsonEncode(novo), 201);
    }

    if (id == null) {
      return http.Response(jsonEncode(acervo), 200);
    }

    for (final item in acervo) {
      if (item['id'] == id) {
        if (pedido.method == 'DELETE') {
          if (bloqueados.contains('${item['status']}'.toLowerCase())) {
            return http.Response(
              jsonEncode({
                'detail': "Não é permitido apagar agendamento com status '${item['status']}'.",
              }),
              409,
            );
          }
          acervo.remove(item);
          return http.Response('', 204);
        }
        if (pedido.method == 'PUT') {
          item.addAll(jsonDecode(pedido.body));
        }
        return http.Response(jsonEncode(item), 200);
      }
    }
    return http.Response(jsonEncode({'detail': 'Agendamento $id não encontrado.'}), 404);
  });
}

Widget appDeMentira(SessaoService sessao, {http.Client? clienteHttp}) {
  final repositorio = AgendamentoRepository(cliente: clienteHttp ?? agendamentosDeMentira());
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: sessao),
      Provider.value(value: AgendamentoService(repositorio, sessao)),
    ],
    child: const AgendaGraosApp(),
  );
}

Future<void> abrirOsAgendamentos(WidgetTester tester, http.Client cliente) async {
  final sessao = sessaoDeMentira(guardado: {'token': 'token-de-ana@biblioteca.com'});
  await sessao.restaurar();
  await tester.pumpWidget(appDeMentira(sessao, clienteHttp: cliente));
  await tester.pumpAndSettle();

  expect(find.byType(InicioScreen), findsOneWidget);
  await tester.tap(find.text('Ver os agendamentos'));
  await tester.pumpAndSettle();
}

Future<void> preencherOFormulario(
  WidgetTester tester,
  String produtor,
  String tipoGrao,
  String quantidade,
) async {
  await tester.tap(find.byTooltip('Novo agendamento'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).at(0), produtor);
  await tester.enterText(find.byType(TextFormField).at(1), tipoGrao);
  await tester.enterText(find.byType(TextFormField).at(2), quantidade);
}

Future<void> excluirRespondendo(WidgetTester tester, String resposta) async {
  await tester.tap(find.text('Excluir'));
  await tester.pumpAndSettle();
  await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text(resposta)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a tela de agendamentos mostra a lista: um ListTile por agendamento', (tester) async {
    await abrirOsAgendamentos(tester, agendamentosDeMentira());
    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.text('Fazenda Santa Luzia - Soja'), findsOneWidget);
    expect(find.text('Sítio Boa Vista - Milho'), findsOneWidget);
  });

  testWidgets('sem agendamento nenhum, a tela diz que a lista está vazia', (tester) async {
    final vazio = MockClient((pedido) async => http.Response('[]', 200));
    await abrirOsAgendamentos(tester, vazio);
    expect(find.text('Nenhum agendamento ainda.'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('com a API parada, o erro; o Tentar de novo pede outra vez', (tester) async {
    var noAr = false;
    final cliente = MockClient((pedido) async {
      if (!noAr) {
        throw http.ClientException('Failed to fetch');
      }
      return http.Response(jsonEncode(doisAgendamentos), 200);
    });
    await abrirOsAgendamentos(tester, cliente);
    expect(find.text('Não consegui carregar os agendamentos'), findsOneWidget);
    expect(find.text('Não consegui falar com a API. O uvicorn está rodando?'), findsOneWidget);

    noAr = true;
    await tester.tap(find.widgetWithText(ElevatedButton, 'Tentar de novo'));
    await tester.pumpAndSettle();
    expect(find.text('Fazenda Santa Luzia - Soja'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsNothing);
  });

  testWidgets('enquanto a resposta não chega, a tela mostra o carregando', (tester) async {
    final resposta = Completer<http.Response>();
    final sessao = sessaoDeMentira(guardado: {'token': 'token-de-ana@biblioteca.com'});
    await sessao.restaurar();
    await tester.pumpWidget(
      appDeMentira(sessao, clienteHttp: MockClient((pedido) => resposta.future)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver os agendamentos'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    resposta.complete(http.Response(jsonEncode(doisAgendamentos), 200));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Fazenda Santa Luzia - Soja'), findsOneWidget);
  });

  testWidgets('tocar num agendamento abre o detalhe, que busca na API pelo id', (tester) async {
    await abrirOsAgendamentos(tester, agendamentosDeMentira());
    pedidos = 0;
    await tester.tap(find.text('Sítio Boa Vista - Milho'));
    await tester.pumpAndSettle();
    expect(find.byType(AgendamentoScreen), findsOneWidget);
    expect(find.text('Milho'), findsOneWidget);
    expect(find.text('30.0 t'), findsOneWidget);
    expect(find.text('confirmado'), findsOneWidget);
    expect(pedidos, 1);
  });

  testWidgets('o detalhe de um agendamento que não existe mostra o erro da API', (tester) async {
    await abrirOsAgendamentos(tester, agendamentosDeMentira());
    Navigator.of(tester.element(find.byType(AgendamentosScreen)))
        .pushNamed(AppRoutes.agendamento, arguments: 99);
    await tester.pumpAndSettle();
    expect(find.text('Não consegui carregar o agendamento'), findsOneWidget);
    expect(find.text('Agendamento não encontrado'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
  });

  testWidgets('sem o id na rota (o F5 no detalhe), a tela mostra a lista', (tester) async {
    await abrirOsAgendamentos(tester, agendamentosDeMentira());
    Navigator.of(tester.element(find.byType(AgendamentosScreen)))
        .pushNamed(AppRoutes.agendamento);
    await tester.pumpAndSettle();
    expect(find.byType(AgendamentoScreen), findsOneWidget);
    expect(find.text('Fazenda Santa Luzia - Soja'), findsOneWidget);
  });

  testWidgets('o menu lateral leva à lista de agendamentos', (tester) async {
    final sessao = sessaoDeMentira(guardado: {'token': 'token-de-ana@biblioteca.com'});
    await sessao.restaurar();
    await tester.pumpWidget(appDeMentira(sessao));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: find.byType(Drawer), matching: find.text('Agendamentos')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AgendamentosScreen), findsOneWidget);
    expect(find.text('Fazenda Santa Luzia - Soja'), findsOneWidget);
  });

  testWidgets('o + abre o formulário vazio, e salvar põe o agendamento novo na lista', (tester) async {
    await abrirOsAgendamentos(tester, acervoDeMentira());
    await preencherOFormulario(tester, 'Fazenda Recanto', 'Trigo', '40');
    expect(find.text('Novo agendamento'), findsOneWidget);

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.byType(FormularioScreen), findsNothing);
    expect(find.byType(ListTile), findsNWidgets(3));
    expect(find.text('Fazenda Recanto - Trigo'), findsOneWidget);
  });

  testWidgets('o validator segura o formulário: com campo errado, nada vai para a API', (tester) async {
    await abrirOsAgendamentos(tester, acervoDeMentira());
    await preencherOFormulario(tester, '', '', '');
    pedidos = 0;

    await tester.tap(find.text('Salvar'));
    await tester.pump();
    expect(find.text('Informe o nome do produtor'), findsOneWidget);
    expect(find.text('Informe o tipo de grão'), findsOneWidget);
    expect(find.text('Informe a quantidade em toneladas, maior que zero'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Fazenda Recanto');
    await tester.enterText(find.byType(TextFormField).at(1), 'Trigo');
    await tester.enterText(find.byType(TextFormField).at(2), 'muitas');
    await tester.tap(find.text('Salvar'));
    await tester.pump();

    expect(find.text('Informe o nome do produtor'), findsNothing);
    expect(find.text('Informe o tipo de grão'), findsNothing);
    expect(find.text('Informe a quantidade em toneladas, maior que zero'), findsOneWidget);
    expect(pedidos, 0);
    expect(find.byType(FormularioScreen), findsOneWidget);
  });

  testWidgets('agendamento repetido: a API recusa (409), e o formulário mostra a frase e fica aberto', (tester) async {
    await abrirOsAgendamentos(tester, acervoDeMentira());
    await preencherOFormulario(tester, 'Fazenda Santa Luzia', 'Soja', '10');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(
      find.text("O produtor 'Fazenda Santa Luzia' já possui um agendamento para 'Soja'."),
      findsOneWidget,
    );
    expect(find.byType(FormularioScreen), findsOneWidget);
  });

  testWidgets('editar: o formulário vem preenchido, e salvar volta para a lista, já atualizada', (tester) async {
    await abrirOsAgendamentos(tester, acervoDeMentira());
    await tester.tap(find.text('Fazenda Santa Luzia - Soja'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    expect(find.text('Editar agendamento'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Fazenda Santa Luzia'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '50.0'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(2), '55');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.byType(FormularioScreen), findsNothing);
    expect(find.byType(AgendamentoScreen), findsNothing);
    expect(find.text('55.0t (pendente)'), findsOneWidget);
    expect(find.text('50.0t (pendente)'), findsNothing);
  });

  testWidgets('excluir pergunta antes: Cancelar deixa o agendamento; Excluir o tira da lista', (tester) async {
    await abrirOsAgendamentos(tester, acervoDeMentira());
    await tester.tap(find.text('Fazenda Santa Luzia - Soja'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    expect(find.text('Excluir agendamento de Fazenda Santa Luzia?'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(AgendamentoScreen), findsOneWidget);

    await excluirRespondendo(tester, 'Excluir');
    expect(find.byType(AgendamentoScreen), findsNothing);
    expect(find.text('Fazenda Santa Luzia - Soja'), findsNothing);
    expect(find.byType(ListTile), findsOneWidget);
  });

  testWidgets('a API não deixa excluir o agendamento em transporte (409): o detalhe mostra a frase', (tester) async {
    await abrirOsAgendamentos(tester, acervoDeMentira());
    await tester.tap(find.text('Sítio Boa Vista - Milho'));
    await tester.pumpAndSettle();
    await excluirRespondendo(tester, 'Excluir');

    expect(
      find.text("Não é permitido apagar agendamento com status 'em transporte'."),
      findsOneWidget,
    );
    expect(find.byType(AgendamentoScreen), findsOneWidget);
  });

  testWidgets('depois de um F5 no formulário (a primeira tela da pilha), ele mostra a lista', (tester) async {
    await abrirOsAgendamentos(tester, acervoDeMentira());
    Navigator.of(tester.element(find.byType(AgendamentosScreen))).pushNamedAndRemoveUntil(
      AppRoutes.formulario,
      (rota) => false,
    );
    await tester.pumpAndSettle();

    expect(find.byType(FormularioScreen), findsOneWidget);
    expect(find.text('Novo agendamento'), findsNothing);
    expect(find.text('Fazenda Santa Luzia - Soja'), findsOneWidget);
  });

  test('o repositório manda o token no cabeçalho e devolve objetos Agendamento', () async {
    String? cabecalho;
    final cliente = MockClient((pedido) async {
      cabecalho = pedido.headers['Authorization'];
      return http.Response(jsonEncode(doisAgendamentos), 200);
    });
    final lista = await AgendamentoRepository(cliente: cliente).listar('tk-123');
    expect(cabecalho, 'Bearer tk-123');
    expect(lista, hasLength(2));
    expect(lista.first, isA<Agendamento>());
    expect(lista.first.produtor, 'Fazenda Santa Luzia');
    expect(lista.last.status, 'confirmado');
  });

  test('o repositório busca um agendamento só pelo id: GET /agendamentos/2', () async {
    String? caminho;
    String? cabecalho;
    final cliente = MockClient((pedido) async {
      caminho = pedido.url.path;
      cabecalho = pedido.headers['Authorization'];
      return http.Response(jsonEncode(doisAgendamentos.last), 200);
    });
    final item = await AgendamentoRepository(cliente: cliente).buscar('tk-123', 2);
    expect(caminho, '/agendamentos/2');
    expect(cabecalho, 'Bearer tk-123');
    expect(item.produtor, 'Sítio Boa Vista');
  });

  test('o repositório cria com POST: o agendamento em JSON no corpo, e o token no cabeçalho', () async {
    late http.Request enviado;
    final cliente = MockClient((pedido) async {
      enviado = pedido;
      return http.Response(
        jsonEncode({
          'id': 3,
          'produtor': 'Fazenda Recanto',
          'tipo_grao': 'Trigo',
          'quantidade_toneladas': 40.0,
          'status': 'pendente',
          'dono_id': 1,
        }),
        201,
      );
    });
    final item = await AgendamentoRepository(cliente: cliente)
        .criar('tk-123', 'Fazenda Recanto', 'Trigo', 40.0, 'pendente');
    expect(enviado.method, 'POST');
    expect(enviado.url.path, '/agendamentos/');
    expect(enviado.headers['Authorization'], 'Bearer tk-123');
    expect(enviado.headers['Content-Type'], startsWith('application/json'));
    expect(jsonDecode(enviado.body), {
      'produtor': 'Fazenda Recanto',
      'tipo_grao': 'Trigo',
      'quantidade_toneladas': 40.0,
      'status': 'pendente',
    });
    expect(item.id, 3);
  });

  test('o repositório edita com PUT e exclui com DELETE, no endereço do agendamento', () async {
    final feitos = <String>[];
    final cliente = MockClient((pedido) async {
      feitos.add('${pedido.method} ${pedido.url.path}');
      if (pedido.method == 'DELETE') {
        return http.Response('', 204);
      }
      return http.Response(jsonEncode(doisAgendamentos.first), 200);
    });
    final repositorio = AgendamentoRepository(cliente: cliente);
    await repositorio.atualizar('tk-123', 1, 'Fazenda Santa Luzia', 'Soja', 55.0, 'pendente');
    await repositorio.excluir('tk-123', 1);
    expect(feitos, ['PUT /agendamentos/1', 'DELETE /agendamentos/1']);
  });

  test('o 422 da API vira a frase da tela: o campo e a mensagem, sem o Value error', () async {
    final sessao = sessaoDeMentira();
    await sessao.entrar('ana@biblioteca.com', 'segredo123');
    final recusa = MockClient((pedido) async {
      return http.Response(
        jsonEncode({
          'detail': [
            {
              'type': 'value_error',
              'loc': ['body', 'produtor'],
              'msg': 'Value error, O nome do produtor precisa ter pelo menos 2 caracteres',
            },
          ],
        }),
        422,
      );
    });
    final servico = AgendamentoService(AgendamentoRepository(cliente: recusa), sessao);
    await expectLater(
      servico.criar('A', 'Soja', 10.0, 'pendente'),
      throwsA(
        isA<ErroDeAgendamentos>().having(
          (e) => '$e',
          'texto',
          'produtor: O nome do produtor precisa ter pelo menos 2 caracteres',
        ),
      ),
    );
  });

  test('o service traduz a recusa: a frase da API vai para a tela', () async {
    final sessao = sessaoDeMentira();
    await sessao.entrar('ana@biblioteca.com', 'segredo123');
    final recusa = MockClient(
      (pedido) async => http.Response('{"detail": "Token invalido ou vencido"}', 401),
    );
    final servico = AgendamentoService(AgendamentoRepository(cliente: recusa), sessao);
    await expectLater(
      servico.listar(),
      throwsA(isA<ErroDeAgendamentos>().having((e) => '$e', 'texto', 'Token invalido ou vencido')),
    );
  });
}