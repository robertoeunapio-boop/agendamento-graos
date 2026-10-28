import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/agendamento.dart';
import '../routes.dart';
import '../services/agendamento_service.dart';
import '../theme/app_theme.dart';
import '../theme/status_visual.dart';
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 64, color: Cores.terra),
                    const SizedBox(height: 16),
                    const Text(
                      'Não consegui carregar o agendamento',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Cores.perigo, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: tentarDeNovo,
                      child: const Text('Tentar de novo'),
                    ),
                  ],
                ),
              ),
            );
          }

          final item = snapshot.data!;
          final visual = statusVisual(item.status);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Cores.verdeClaro,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: visual.cor, width: 1.5),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: Cores.verdeFolha),
                      title: const Text('Produtor'),
                      subtitle: Text(
                        item.produtor,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.grass, color: Cores.verdeFolha),
                      title: const Text('Tipo de Grão'),
                      subtitle: Text(
                        item.tipoGrao,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.scale, color: Cores.verdeFolha),
                      title: const Text('Quantidade'),
                      subtitle: Text(
                        '${item.quantidadeToneladas} t',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListTile(
                      leading: Icon(visual.icone, color: visual.cor),
                      title: const Text('Status'),
                      subtitle: Text(
                        item.status,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: visual.cor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => editar(item),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Cores.perigo,
                        side: const BorderSide(color: Cores.perigo, width: 1.5),
                      ),
                      onPressed: () => excluir(item),
                      icon: const Icon(Icons.delete),
                      label: const Text('Excluir'),
                    ),
                  ),
                ],
              ),
              if (erro != null) ...[
                const SizedBox(height: 16),
                Text(
                  erro!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Cores.perigo, fontSize: 16),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}