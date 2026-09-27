import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/sessao_service.dart';
import 'login_screen.dart';

class InicioScreen extends StatelessWidget {
  final SessaoService sessao;

  const InicioScreen({super.key, required this.sessao});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Início'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              sessao.sair();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(sessao: sessao),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Usuario>(
        future: sessao.buscarUsuarioLogado(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar usuário: ${snapshot.error}'),
            );
          }

          final usuario = snapshot.data!;

          return Center(
            child: Column(
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
          );
        },
      ),
    );
  }
}