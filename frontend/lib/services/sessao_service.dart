import '../models/usuario.dart';
import '../repositories/usuario_repository.dart';

class ErroDeLogin implements Exception {
  final String mensagem;
  ErroDeLogin(this.mensagem);
}

class SessaoService {
  final UsuarioRepository repositorio;
  String? _token;

  SessaoService({required this.repositorio});

  String? get token => _token;
  bool get estaLogado => _token != null;

  Future<void> entrar(String email, String senha) async {
    if (email.trim().isEmpty || senha.trim().isEmpty) {
      throw ErroDeLogin('Preencha o e-mail e a senha');
    }

    final recebido = await repositorio.entrar(email.trim(), senha.trim());

    if (recebido == null) {
      throw ErroDeLogin('E-mail ou senha incorretos');
    }

    _token = recebido;
  }

  Future<Usuario> buscarUsuarioLogado() async {
    if (_token == null) {
      throw Exception('Usuário não autenticado');
    }
    return await repositorio.quemSouEu(_token!);
  }

  void sair() {
    _token = null;
  }
}