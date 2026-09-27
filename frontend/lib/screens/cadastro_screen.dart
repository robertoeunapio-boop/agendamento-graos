import 'package:flutter/material.dart';
import '../repositories/usuario_repository.dart';

class CadastroScreen extends StatefulWidget {
  final UsuarioRepository repositorio;

  const CadastroScreen({super.key, required this.repositorio});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;
  String? _mensagem;
  bool _sucesso = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      setState(() {
        _sucesso = false;
        _mensagem = 'Preencha todos os campos.';
      });
      return;
    }

    if (senha.length < 6) {
      setState(() {
        _sucesso = false;
        _mensagem = 'A senha deve ter no mínimo 6 caracteres.';
      });
      return;
    }

    setState(() {
      _carregando = true;
      _mensagem = null;
    });

    final erro = await widget.repositorio.cadastrar(nome, email, senha);

    setState(() {
      _carregando = false;
      _sucesso = erro == null;
      _mensagem = erro ?? 'Conta criada com sucesso! Volte e faça login.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar uma conta')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_mensagem != null) ...[
                Text(
                  _mensagem!,
                  style: TextStyle(
                    color: _sucesso ? Colors.green : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _carregando ? null : _cadastrar,
                child: Text(_carregando ? 'Cadastrando...' : 'Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}