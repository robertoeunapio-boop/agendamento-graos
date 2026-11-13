import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/formulario_screen.dart';

Future<void> abrirOFormulario(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: Scaffold()));
  Navigator.of(tester.element(find.byType(Scaffold))).push(
    MaterialPageRoute(builder: (_) => const FormularioScreen()),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('o formulário vazio mostra as três frases', (tester) async {
    await abrirOFormulario(tester);
    await tester.tap(find.text('Salvar'));
    await tester.pump();
    expect(find.text('Informe o nome do produtor'), findsOneWidget);
    expect(find.text('Informe o tipo de grão'), findsOneWidget);
    expect(find.text('Informe a quantidade em toneladas, maior que zero'), findsOneWidget);
  });

  testWidgets('com produtor e grão preenchidos, só a quantidade continua recusada', (tester) async {
    await abrirOFormulario(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'Fazenda Recanto');
    await tester.enterText(find.byType(TextFormField).at(1), 'Trigo');
    await tester.enterText(find.byType(TextFormField).at(2), 'muitas');
    await tester.tap(find.text('Salvar'));
    await tester.pump();
    expect(find.text('Informe o nome do produtor'), findsNothing);
    expect(find.text('Informe o tipo de grão'), findsNothing);
    expect(find.text('Informe a quantidade em toneladas, maior que zero'), findsOneWidget);
  });
}