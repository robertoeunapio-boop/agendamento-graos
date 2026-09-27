import 'package:flutter/material.dart';
import 'repositories/usuario_repository.dart';
import 'screens/login_screen.dart';
import 'services/sessao_service.dart';

void main() {
  final repositorio = UsuarioRepository();
  final sessao = SessaoService(repositorio: repositorio);

  runApp(AgendamentoGraosApp(sessao: sessao));
}

class AgendamentoGraosApp extends StatelessWidget {
  final SessaoService sessao;

  const AgendamentoGraosApp({super.key, required this.sessao});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agendamento de Grãos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: LoginScreen(sessao: sessao),
    );
  }
}