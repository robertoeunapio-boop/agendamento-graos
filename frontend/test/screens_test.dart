import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/main.dart';
import 'package:frontend/repositories/agendamento_repository.dart';
import 'package:frontend/repositories/usuario_repository.dart';
import 'package:frontend/routes.dart';
import 'package:frontend/screens/agendamento_screen.dart';
import 'package:frontend/screens/formulario_screen.dart';
import 'package:frontend/screens/inicio_screen.dart';
import 'package:frontend/services/agendamento_service.dart';
import 'package:frontend/services/sessao_service.dart';

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
  final List<Map<String, dynamic>> acervo = [
    {
      'id': 1,
      'produtor': 'Fazenda Santa Luzia',
      'tipo_grao': 'Soja',
      'quantidade_toneladas': 50.0,
      'status': 'pendente',
      'dono_id': 1
    },
    {
      'id': 2,
      'produtor': 'Sítio Boa Vista',
      'tipo_grao': 'Milho',
      'quantidade_toneladas': 30.0,
      'status': 'confirmado',
      'dono_id': 1
    },
  ];

  return MockClient((pedido) async {
    pedidos++;
    final segments = pedido.url.pathSegments.where((s) => s.isNotEmpty).toList();
    final idStr = segments.length > 1 ? segments.last : null;
    final id = idStr != null ? int.tryParse(idStr) : null;

    if (pedido.method == 'POST') {
      final dados = jsonDecode(pedido.body);
      if ((dados['produtor'] as String).length < 2) {
        return http.Response(
          jsonEncode({
            'detail': [
              {'loc': ['body', 'produtor'], 'msg': 'Value error, o nome do produtor precisa ter pelo menos 2 caracteres'}
            ]
          }),
          422,
        );
      }
      final novo = {
        'id': 3,
        'produtor': dados['produtor'],
        'tipo_grao': dados['tipo_grao'],
        'quantidade_toneladas': (dados['quantidade_toneladas'] as num).toDouble(),
        'status': dados['status'] ?? 'pendente',
        'dono_id': 1,
      };
      acervo.add(novo);
      return http.Response(jsonEncode(novo), 201);
    }

    if (id != null) {
      final index = acervo.indexWhere((item) => item['id'] == id);
      if (index == -1) {
        return http.Response('{"detail": "Agendamento não encontrado"}', 404);
      }

      if (pedido.method == 'DELETE') {
        acervo.removeAt(index);
        return http.Response('', 204);
      }

      if (pedido.method == 'PUT') {
        final dados = jsonDecode(pedido.body);
        acervo[index]['produtor'] = dados['produtor'];
        acervo[index]['tipo_grao'] = dados['tipo_grao'];
        acervo[index]['quantidade_toneladas'] = (dados['quantidade_toneladas'] as num).toDouble();
        acervo[index]['status'] = dados['status'];
        return http.Response(jsonEncode(acervo[index]), 200);
      }

      return http.Response(jsonEncode(acervo[index]), 200);
    }

    return http.Response(jsonEncode(acervo), 200);
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

  final element = tester.element(find.byType(InicioScreen));
  Navigator.pushNamed(element, AppRoutes.agendamentos);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('exibe a lista de agendamentos vinda da API', (tester) async {
    await abrirOsAgendamentos(tester, agendamentosDeMentira());
    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.text('Fazenda Santa Luzia - Soja'), findsOneWidget);
    expect(find.text('Sítio Boa Vista - Milho'), findsOneWidget);
  });

  testWidgets('o botão + abre o formulário vazio e grava um novo agendamento', (tester) async {
    await abrirOsAgendamentos(tester, agendamentosDeMentira());
    await tester.tap(find.byTooltip('Novo agendamento'));
    await tester.pumpAndSettle();

    expect(find.text('Novo Agendamento'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Fazenda Recanto');
    await tester.enterText(find.byType(TextFormField).at(1), 'Trigo');
    await tester.enterText(find.byType(TextFormField).at(2), '40.0');

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.byType(FormularioScreen), findsNothing);
    expect(find.byType(ListTile), findsNWidgets(3));
    expect(find.text('Fazenda Recanto - Trigo'), findsOneWidget);
  });

  testWidgets('validação do formulário segura dados inválidos no app', (tester) async {
    await abrirOsAgendamentos(tester, agendamentosDeMentira());
    await tester.tap(find.byTooltip('Novo agendamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salvar'));
    await tester.pump();

    expect(find.text('Informe o nome do produtor (mínimo 2 caracteres)'), findsOneWidget);
    expect(find.text('Informe o tipo de grão (mínimo 2 caracteres)'), findsOneWidget);
  });

  testWidgets('editar altera os dados e atualiza a listagem ao voltar', (tester) async {
    await abrirOsAgendamentos(tester, agendamentosDeMentira());
    await tester.tap(find.text('Fazenda Santa Luzia - Soja'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    expect(find.text('Editar Agendamento'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Fazenda Santa Luzia Editada');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.byType(FormularioScreen), findsNothing);
    expect(find.byType(AgendamentoScreen), findsNothing);
    expect(find.text('Fazenda Santa Luzia Editada - Soja'), findsOneWidget);
  });

  testWidgets('excluir abre diálogo e remove o item ao confirmar', (tester) async {
    await abrirOsAgendamentos(tester, agendamentosDeMentira());
    await tester.tap(find.text('Fazenda Santa Luzia - Soja'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    expect(find.text('Excluir agendamento de Fazenda Santa Luzia?'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Excluir'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AgendamentoScreen), findsNothing);
    expect(find.text('Fazenda Santa Luzia - Soja'), findsNothing);
    expect(find.byType(ListTile), findsOneWidget);
  });
}