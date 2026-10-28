import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/agendamento.dart';
import 'repositories/agendamento_repository.dart';
import 'repositories/token_repository.dart';
import 'repositories/usuario_repository.dart';
import 'routes.dart';
import 'screens/agendamento_screen.dart';
import 'screens/agendamentos_screen.dart';
import 'screens/cadastro_screen.dart';
import 'screens/formulario_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/login_screen.dart';
import 'services/agendamento_service.dart';
import 'services/sessao_service.dart';
import 'theme/app_theme.dart';
import 'widgets/rota_protegida.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sessao = SessaoService(UsuarioRepository(), tokens: TokenRepository());
  await sessao.restaurar();
  final agendamentos = AgendamentoService(AgendamentoRepository(), sessao);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sessao),
        Provider.value(value: agendamentos),
      ],
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
      theme: temaDoApp(),
      builder: (context, child) => ColoredBox(
        color: Cores.verdeClaro,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: child,
          ),
        ),
      ),
      initialRoute: AppRoutes.inicio,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.cadastro: (context) => const CadastroScreen(),
        AppRoutes.inicio: (context) => const RotaProtegida(tela: InicioScreen()),
        AppRoutes.agendamentos: (context) => const RotaProtegida(tela: AgendamentosScreen()),
        AppRoutes.agendamento: (context) => RotaProtegida(
          tela: AgendamentoScreen(id: ModalRoute.of(context)!.settings.arguments as int?),
        ),
        AppRoutes.formulario: (context) => RotaProtegida(
          tela: FormularioScreen(
            agendamento: ModalRoute.of(context)!.settings.arguments as Agendamento?,
          ),
        ),
      },
    );
  }
}