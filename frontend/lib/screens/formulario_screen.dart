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
  final quantidade = TextEditingController();
  final status = TextEditingController();
  bool salvando = false;
  String? erro;

  @override
  void initState() {
    super.initState();
    if (widget.agendamento != null) {
      produtor.text = widget.agendamento!.produtor;
      tipoGrao.text = widget.agendamento!.tipoGrao;
      quantidade.text = '${widget.agendamento!.quantidadeToneladas}';
      status.text = widget.agendamento!.status;
    } else {
      status.text = 'pendente';
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
    final toneladas = double.parse(quantidade.text.trim().replaceFirst(',', '.'));
    try {
      if (widget.agendamento == null) {
        await servico.criar(
          produtor.text.trim(),
          tipoGrao.text.trim(),
          toneladas,
          status.text.trim(),
        );
      } else {
        await servico.atualizar(
          widget.agendamento!.id,
          produtor.text.trim(),
          tipoGrao.text.trim(),
          toneladas,
          status.text.trim(),
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
    quantidade.dispose();
    status.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.isFirst) {
      return const AgendamentosScreen();
    }

    final editando = widget.agendamento != null;

    return Scaffold(
      appBar: AppBar(title: Text(editando ? 'Editar agendamento' : 'Novo agendamento')),
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
                      if ((valor ?? '').trim().isEmpty) {
                        return 'Informe o nome do produtor';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: tipoGrao,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de grão',
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if ((valor ?? '').trim().isEmpty) {
                        return 'Informe o tipo de grão';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: quantidade,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade (toneladas)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (valor) {
                      final numero = double.tryParse(
                        (valor ?? '').trim().replaceFirst(',', '.'),
                      );
                      if (numero == null || numero <= 0) {
                        return 'Informe a quantidade em toneladas, maior que zero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if ((valor ?? '').trim().isEmpty) {
                        return 'Informe o status';
                      }
                      return null;
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