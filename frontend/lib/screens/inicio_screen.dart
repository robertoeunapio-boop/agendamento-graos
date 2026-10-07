import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sessao_service.dart';
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
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Olá, ${usuario.nome}!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    usuario.email,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }
}