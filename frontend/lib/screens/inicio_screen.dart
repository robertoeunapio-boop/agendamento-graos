import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes.dart';
import '../services/sessao_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<SessaoService>().usuario;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Início'),
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: usuario == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 44,
                      backgroundColor: Cores.verdeProfundo,
                      child: Icon(Icons.agriculture, size: 48, color: Cores.dourado),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Olá, ${usuario.nome}!',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Cores.verdeProfundo,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      usuario.email,
                      style: const TextStyle(color: Cores.terra, fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.agendamentos);
                        },
                        icon: const Icon(Icons.agriculture),
                        label: const Text('Ver os agendamentos'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}