import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/usuario_repository.dart';
import 'routes.dart';
import 'screens/cadastro_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/login_screen.dart';
import 'services/sessao_service.dart';
import 'widgets/rota_protegida.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SessaoService(repositorio: UsuarioRepository()),
      child: const AgendaGraosApp(),
    ),
  );
}

class AgendaGraosApp extends StatelessWidget {
  const AgendaGraosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda de Grãos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.cadastro: (context) => const CadastroScreen(),
        AppRoutes.inicio: (context) => const RotaProtegida(tela: InicioScreen()),
      },
    );
  }
}