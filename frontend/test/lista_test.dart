import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:frontend/repositories/agendamento_repository.dart';
import 'package:frontend/repositories/usuario_repository.dart';
import 'package:frontend/screens/agendamentos_screen.dart';
import 'package:frontend/services/agendamento_service.dart';
import 'package:frontend/services/sessao_service.dart';

Future<void> abrirALista(WidgetTester tester, String respostaDaApi) async {
  final api = MockClient((pedido) async => http.Response(respostaDaApi, 200));
  final sessao = SessaoService(UsuarioRepository());
  sessao.token = 'um-token';
  final agendamentos = AgendamentoService(AgendamentoRepository(cliente: api), sessao);
  await tester.pumpWidget(
    Provider.value(
      value: agendamentos,
      child: const MaterialApp(home: AgendamentosScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a lista mostra o agendamento que a API devolveu', (tester) async {
    await abrirALista(
      tester,
      '[{"id": 1, "produtor": "Fazenda Santa Luzia", "tipo_grao": "Soja", "quantidade_toneladas": 50.0, "status": "pendente", "dono_id": 1}]',
    );
    expect(find.text('Fazenda Santa Luzia - Soja'), findsOneWidget);
    expect(find.text('Nenhum agendamento ainda.'), findsNothing);
  });

  testWidgets('sem agendamento nenhum, a lista avisa que está vazia', (tester) async {
    await abrirALista(tester, '[]');
    expect(find.text('Nenhum agendamento ainda.'), findsOneWidget);
  });
}