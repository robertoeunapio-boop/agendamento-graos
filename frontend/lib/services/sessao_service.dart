import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../repositories/usuario_repository.dart';

class ErroDeLogin implements Exception {
  final String mensagem;
  ErroDeLogin(this.mensagem);
}

class SessaoService extends ChangeNotifier {
  final UsuarioRepository repositorio;
  String? _token;
  Usuario? _usuario;

  SessaoService({required this.repositorio});

  String? get token => _token;
  Usuario? get usuario => _usuario;
  bool get estaLogado => _token != null;

  Future<void> entrar(String email, String senha) async {
    if (email.trim().isEmpty || senha.trim().isEmpty) {
      throw ErroDeLogin('Preencha o e-mail e a senha');
    }

    String? recebido;
    Usuario? quem;

    try {
      recebido = await repositorio.entrar(email.trim(), senha.trim());
      if (recebido != null) {
        quem = await repositorio.quemSouEu(recebido);
      }
    } catch (e) {
      throw ErroDeLogin('Não consegui falar com a API. O uvicorn está a rodar?');
    }

    if (recebido == null) {
      throw ErroDeLogin('E-mail ou senha incorretos');
    }

    _token = recebido;
    _usuario = quem;
    
    notifyListeners();
  }

  void sair() {
    _token = null;
    _usuario = null;
    
    notifyListeners();
  }
}