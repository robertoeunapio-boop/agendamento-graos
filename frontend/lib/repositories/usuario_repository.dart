import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class UsuarioRepository {
  final String baseUrl;
  final http.Client cliente;

  UsuarioRepository({
    this.baseUrl = 'http://127.0.0.1:8000',
    http.Client? cliente,
  }) : cliente = cliente ?? http.Client();

  Future<String?> entrar(String email, String senha) async {
    final resposta = await cliente.post(
      Uri.parse('$baseUrl/usuarios/login'),
      body: {'username': email, 'password': senha},
    );

    if (resposta.statusCode != 200) {
      return null;
    }

    final corpo = jsonDecode(resposta.body);
    return corpo['access_token'];
  }

  Future<Usuario> quemSouEu(String token) async {
    final resposta = await cliente.get(
      Uri.parse('$baseUrl/usuarios/eu'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resposta.statusCode != 200) {
      throw Exception('Falha ao autenticar token');
    }

    return Usuario.fromJson(jsonDecode(resposta.body));
  }

  Future<String?> cadastrar(String nome, String email, String senha) async {
    final resposta = await cliente.post(
      Uri.parse('$baseUrl/usuarios/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
      },
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'senha': senha,
      }),
    );

    if (resposta.statusCode == 201) {
      return null; 
    }

    if (resposta.statusCode == 422) {
      return 'A senha deve ter no mínimo 6 caracteres e o e-mail deve ser válido.';
    }

    if (resposta.statusCode == 409) {
      return 'Este e-mail já está cadastrado no sistema.';
    }

    return 'Erro ao criar conta. Tente novamente.';
  }
}