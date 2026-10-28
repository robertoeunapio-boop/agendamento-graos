import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/agendamento.dart';
import '../routes.dart';
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
  String? erro;

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

  Future<void> editar(Agendamento agendamento) async {
    final salvou = await Navigator.pushNamed(
      context,
      AppRoutes.formulario,
      arguments: agendamento,
    );
    if (salvou == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> excluir(Agendamento agendamento) async {
    final certeza = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir agendamento de ${agendamento.produtor}?'),
        content: const Text('Tem certeza? O agendamento sai da sua lista, e não dá para desfazer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (certeza != true || !mounted) {
      return;
    }
    try {
      await context.read<AgendamentoService>().excluir(agendamento.id);
    } on ErroDeAgendamentos catch (e) {
      setState(() {
        erro = '$e';
      });
      return;
    }
    if (!mounted) return;
    Navigator.pop(context, true);
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => editar(item),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => excluir(item),
                    icon: const Icon(Icons.delete),
                    label: const Text('Excluir'),
                  ),
                ],
              ),
              if (erro != null) ...[
                const SizedBox(height: 16),
                Text(
                  erro!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}