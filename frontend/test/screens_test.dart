import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend/repositories/usuario_repository.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/services/sessao_service.dart';

void main() {
  testWidgets('Deve renderizar a tela de login corretamente', (WidgetTester tester) async {
    final repositorio = UsuarioRepository();
    final sessaoService = SessaoService(repositorio: repositorio);

    await tester.pumpWidget(
      ChangeNotifierProvider<SessaoService>.value(
        value: sessaoService,
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('Agenda de Grãos'), findsOneWidget);
    expect(find.text('Entrar'), findsWidgets);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}