import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/agendamento.dart';
import '../services/agendamento_service.dart';
import 'agendamentos_screen.dart';

class FormularioScreen extends StatefulWidget {
  const FormularioScreen({super.key, this.agendamento});
  final Agendamento? agendamento;

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final chave = GlobalKey<FormState>();
  final produtor = TextEditingController();
  final tipoGrao = TextEditingController();
  final quantidadeToneladas = TextEditingController();
  String status = 'pendente';
  bool salvando = false;
  String? erro;

  @override
  void initState() {
    super.initState();
    if (widget.agendamento != null) {
      produtor.text = widget.agendamento!.produtor;
      tipoGrao.text = widget.agendamento!.tipoGrao;
      quantidadeToneladas.text = '${widget.agendamento!.quantidadeToneladas}';
      status = widget.agendamento!.status;
    }
  }

  Future<void> salvar() async {
    if (!chave.currentState!.validate()) {
      return;
    }

    setState(() {
      salvando = true;
      erro = null;
    });

    final servico = context.read<AgendamentoService>();
    final qtd = double.parse(quantidadeToneladas.text.replaceFirst(',', '.'));

    try {
      if (widget.agendamento == null) {
        await servico.criar(produtor.text, tipoGrao.text, qtd, status);
      } else {
        await servico.atualizar(
          widget.agendamento!.id,
          produtor.text,
          tipoGrao.text,
          qtd,
          status,
        );
      }
    } on ErroDeAgendamentos catch (e) {
      setState(() {
        salvando = false;
        erro = '$e';
      });
      return;
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    produtor.dispose();
    tipoGrao.dispose();
    quantidadeToneladas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.isFirst) {
      return const AgendamentosScreen();
    }
    final editando = widget.agendamento != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar Agendamento' : 'Novo Agendamento'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: chave,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: produtor,
                    decoration: const InputDecoration(
                      labelText: 'Produtor',
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if ((valor ?? '').trim().length < 2) {
                        return 'Informe o nome do produtor (mínimo 2 caracteres)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: tipoGrao,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Grão',
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if ((valor ?? '').trim().length < 2) {
                        return 'Informe o tipo de grão (mínimo 2 caracteres)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: quantidadeToneladas,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade (Toneladas)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (valor) {
                      final parsed = double.tryParse((valor ?? '').replaceFirst(',', '.'));
                      if (parsed == null || parsed <= 0) {
                        return 'Informe uma quantidade válida (maior que 0)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'pendente', child: Text('Pendente')),
                      DropdownMenuItem(value: 'confirmado', child: Text('Confirmado')),
                      DropdownMenuItem(value: 'cancelado', child: Text('Cancelado')),
                    ],
                    onChanged: (novoStatus) {
                      if (novoStatus != null) {
                        setState(() {
                          status = novoStatus;
                        });
                      }
                    },
                  ),
                  if (erro != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      erro!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: salvando ? null : salvar,
                    child: Text(salvando ? 'Salvando...' : 'Salvar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}