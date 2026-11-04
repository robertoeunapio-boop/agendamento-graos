import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/agendamento.dart';
import '../routes.dart';
import '../services/agendamento_service.dart';
import '../theme/app_theme.dart';
import '../theme/status_visual.dart';
import '../widgets/app_drawer.dart';

class AgendamentosScreen extends StatefulWidget {
  const AgendamentosScreen({super.key});

  @override
  State<AgendamentosScreen> createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen> {
  late Future<List<Agendamento>> agendamentos;
  String busca = '';
  bool soEmTransporte = false;
  final campoDaBusca = TextEditingController();

  @override
  void initState() {
    super.initState();
    agendamentos = context.read<AgendamentoService>().listar();
  }

  @override
  void dispose() {
    campoDaBusca.dispose();
    super.dispose();
  }

  void pedirDeNovo() {
    setState(() {
      agendamentos = context.read<AgendamentoService>().listar(
            busca: busca,
            status: soEmTransporte ? 'em transporte' : '',
          );
    });
  }

  void buscar(String texto) {
    busca = texto.trim();
    pedirDeNovo();
  }

  void limparABusca() {
    campoDaBusca.clear();
    buscar('');
  }

  void filtrar(bool ligado) {
    soEmTransporte = ligado;
    pedirDeNovo();
  }

  Widget vazio(IconData icone, String titulo, String? dica) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 72, color: Cores.verdeFolha),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (dica != null) ...[
              const SizedBox(height: 8),
              Text(
                dica,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Cores.terra),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget listaDosAgendamentos() {
    return FutureBuilder<List<Agendamento>>(
      future: agendamentos,
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
                    'Não consegui carregar os agendamentos',
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
                    onPressed: pedirDeNovo,
                    child: const Text('Tentar de novo'),
                  ),
                ],
              ),
            ),
          );
        }

        final lista = snapshot.data!;

        if (lista.isEmpty) {
          if (busca.isNotEmpty) {
            return vazio(
              Icons.search_off,
              'Nenhum agendamento com "$busca" no produtor.',
              null,
            );
          }
          if (soEmTransporte) {
            return vazio(
              Icons.local_shipping,
              'Nenhum agendamento em transporte agora.',
              null,
            );
          }
          return vazio(
            Icons.agriculture,
            'Nenhum agendamento ainda.',
            'Toque em Novo para criar o primeiro.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: lista.length,
          itemBuilder: (context, i) {
            final item = lista[i];
            final visual = statusVisual(item.status);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Cores.verdeClaro,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: visual.cor, width: 1.5),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: visual.cor,
                  child: Icon(visual.icone, color: Colors.white),
                ),
                title: Text(
                  '${item.produtor} - ${item.tipoGrao}',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${item.quantidadeToneladas}t (${item.status})',
                  style: const TextStyle(fontSize: 15),
                ),
                trailing: const Icon(Icons.chevron_right, size: 32),
                onTap: () async {
                  final mudou = await Navigator.pushNamed(
                    context,
                    AppRoutes.agendamento,
                    arguments: item.id,
                  );
                  if (mudou == true) {
                    pedirDeNovo();
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendamentos')),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: campoDaBusca,
              decoration: InputDecoration(
                labelText: 'Buscar pelo produtor',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Limpar a busca',
                  onPressed: limparABusca,
                ),
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: buscar,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: const Text('Só em transporte'),
                avatar: const Icon(Icons.local_shipping, size: 18),
                selected: soEmTransporte,
                onSelected: filtrar,
              ),
            ),
          ),
          Expanded(child: listaDosAgendamentos()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Novo agendamento',
        onPressed: () async {
          final salvou = await Navigator.pushNamed(context, AppRoutes.formulario);
          if (salvou == true) {
            pedirDeNovo();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
    );
  }
}