import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/agendamento.dart';
import '../services/agendamento_service.dart';
import 'agendamentos_screen.dart';

class AgendamentoScreen extends StatefulWidget {
  const AgendamentoScreen({super.key, this.id});

  final int? id;

  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  late Future<Agendamento> pedido;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      pedido = context.read<AgendamentoService>().buscar(widget.id!);
    }
  }

  void tentarDeNovo() {
    setState(() {
      pedido = context.read<AgendamentoService>().buscar(widget.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.id == null) {
      return const AgendamentosScreen();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Agendamento')),
      body: FutureBuilder<Agendamento>(
        future: pedido,
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
                  const Text('Não consegui carregar o agendamento'),
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

          final item = snapshot.data!;
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Produtor'),
                subtitle: Text(item.produtor),
              ),
              ListTile(
                leading: const Icon(Icons.grass),
                title: const Text('Tipo de Grão'),
                subtitle: Text(item.tipoGrao),
              ),
              ListTile(
                leading: const Icon(Icons.scale),
                title: const Text('Quantidade'),
                subtitle: Text('${item.quantidadeToneladas} t'),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Status'),
                subtitle: Text(item.status),
              ),
            ],
          );
        },
      ),
    );
  }
}