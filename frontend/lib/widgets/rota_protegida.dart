import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';
import '../services/sessao_service.dart';

class RotaProtegida extends StatelessWidget {
  final Widget tela;
  const RotaProtegida({super.key, required this.tela});

  @override
  Widget build(BuildContext context) {
    final sessao = context.watch<SessaoService>();

    if (!sessao.logado) {
      return const LoginScreen();
    }

    return tela;
  }
}