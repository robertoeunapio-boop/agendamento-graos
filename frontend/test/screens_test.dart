import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/main.dart';
import 'package:frontend/repositories/usuario_repository.dart';
import 'package:frontend/screens/cadastro_screen.dart';
import 'package:frontend/services/sessao_service.dart';

int pedidos = 0;

SessaoService sessaoDeMentira({Map<String, Object> guardado = const {}}) {
  SharedPreferences.setMockInitialValues(guardado);
  final contas = {
    'ana@agendagraos.com': {'nome': 'Ana', 'senha': 'segredo123'},
  };
  final cliente = MockClient((pedido) async {
    pedidos++;
    if (pedido.url.path == '/usuarios/' && pedido.method == 'POST') {
      final dados = jsonDecode(pedido.body);
      if (contas.containsKey(dados['email'])) {
        return http.Response(
          '{"detail": "Ja existe uma conta com o e-mail ${dados['email']}"}',
          409,
        );
      }
      if (dados['senha'].length < 6) {
        return http.Response(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'senha'],
                'msg': 'String should have at least 6 characters',
              },
            ],
          }),
          422,
        );
      }
      contas[dados['email']] = {'nome': dados['nome'], 'senha': dados['senha']};
      return http.Response(
        jsonEncode({'id': 2, 'nome': dados['nome'], 'email': dados['email']}),
        201,
      );
    }
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
      final email = (pedido.headers['Authorization'] ?? '').replaceFirst(
        'Bearer token-de-',
        '',
      );
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

Widget appDeMentira(SessaoService sessao) {
  return ChangeNotifierProvider.value(value: sessao, child: const AgendaGraosApp());
}

void main() {
  testWidgets('a tela de login tem e-mail, senha e o botão Entrar', (tester) async {
    await tester.pumpWidget(appDeMentira(sessaoDeMentira()));
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
  });

  testWidgets('a tela de cadastro tem nome, e-mail e senha', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CadastroScreen()));
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.widgetWithText(ElevatedButton, 'Cadastrar'), findsOneWidget);
  });

  testWidgets('restaurar devolve a sessão a quem tem um token guardado', (tester) async {
    final sessao = sessaoDeMentira(guardado: {'token': 'token-de-ana@agendagraos.com'});
    await sessao.restaurar();
    expect(sessao.logado, isTrue);
    expect(sessao.usuario?.nome, 'Ana');
  });
}