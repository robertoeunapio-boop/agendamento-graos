import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/repositories/usuario_repository.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/services/sessao_service.dart';

void main() {
  testWidgets('Renderiza elementos essenciais da LoginScreen',
      (WidgetTester tester) async {
    final repositorio = UsuarioRepository();
    final sessao = SessaoService(repositorio: repositorio);

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(sessao: sessao),
      ),
    );

    expect(find.text('Entrar'), findsWidgets);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Criar uma conta'), findsOneWidget);
  });
}