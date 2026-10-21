import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/agendamento.dart';
import 'usuario_repository.dart';

class AgendamentoRepository {
  AgendamentoRepository({http.Client? cliente}) : cliente = cliente ?? http.Client();
  final http.Client cliente;

  Future<List<Agendamento>> listar(String token) async {
    final resposta = await cliente.get(
      Uri.parse('$enderecoDaApi/agendamentos/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resposta.statusCode != 200) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
    }
    final itens = jsonDecode(resposta.body);
    return [for (final item in itens) Agendamento.fromJson(item)];
  }

  Future<Agendamento> buscar(String token, int id) async {
    final resposta = await cliente.get(
      Uri.parse('$enderecoDaApi/agendamentos/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resposta.statusCode != 200) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
    }
    return Agendamento.fromJson(jsonDecode(resposta.body));
  }

  Future<Agendamento> criar(
    String token,
    String produtor,
    String tipoGrao,
    double quantidadeToneladas,
    String status,
  ) async {
    final resposta = await cliente.post(
      Uri.parse('$enderecoDaApi/agendamentos/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'produtor': produtor,
        'tipo_grao': tipoGrao,
        'quantidade_toneladas': quantidadeToneladas,
        'status': status,
      }),
    );
    if (resposta.statusCode != 201) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
    }
    return Agendamento.fromJson(jsonDecode(resposta.body));
  }

  Future<Agendamento> atualizar(
    String token,
    int id,
    String produtor,
    String tipoGrao,
    double quantidadeToneladas,
    String status,
  ) async {
    final resposta = await cliente.put(
      Uri.parse('$enderecoDaApi/agendamentos/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'produtor': produtor,
        'tipo_grao': tipoGrao,
        'quantidade_toneladas': quantidadeToneladas,
        'status': status,
      }),
    );
    if (resposta.statusCode != 200) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
    }
    return Agendamento.fromJson(jsonDecode(resposta.body));
  }

  Future<void> excluir(String token, int id) async {
    final resposta = await cliente.delete(
      Uri.parse('$enderecoDaApi/agendamentos/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resposta.statusCode != 204) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
    }
  }

  String _frase(String corpo) {
    try {
      final detalhe = jsonDecode(corpo)['detail'];
      if (detalhe is String) {
        return detalhe;
      }
      if (detalhe is List && detalhe.isNotEmpty) {
        final primeiro = detalhe[0];
        final mensagem = '${primeiro['msg']}'.replaceFirst('Value error, ', '');
        return '${primeiro['loc'].last}: $mensagem';
      }
      return 'Erro na requisição.';
    } catch (_) {
      return 'Erro na comunicação com a API.';
    }
  }
}