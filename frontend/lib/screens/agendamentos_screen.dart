import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/agendamento.dart';
import '../routes.dart';
import '../services/agendamento_service.dart';
import '../widgets/app_drawer.dart';

class AgendamentosScreen extends StatefulWidget {
  const AgendamentosScreen({super.key});

  @override
  State<AgendamentosScreen> createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen> {
  late Future<List<Agendamento>> agendamentos;

  @override
  void initState() {
    super.initState();
    agendamentos = context.read<AgendamentoService>().listar();
  }

  void tentarDeNovo() {
    setState(() {
      agendamentos = context.read<AgendamentoService>().listar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendamentos')),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Agendamento>>(
        future: agendamentos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 56),
                  const SizedBox(height: 16),
                  const Text('Não consegui carregar os agendamentos'),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: tentarDeNovo,
                    child: const Text('Tentar de novo'),
                  ),
                ],
              ),
            );
          }

          final lista = snapshot.data!;

          if (lista.isEmpty) {
            return const Center(child: Text('Nenhum agendamento ainda.'));
          }

          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, i) {
              final item = lista[i];
              return ListTile(
                leading: const Icon(Icons.agriculture),
                title: Text('${item.produtor} - ${item.tipoGrao}'),
                subtitle: Text('${item.quantidadeToneladas}t (${item.status})'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.agendamento,
                    arguments: item.id,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}