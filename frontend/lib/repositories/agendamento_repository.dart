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
      throw RecusaDaApi(resposta.statusCode, jsonDecode(resposta.body)['detail']);
    }
    final itens = jsonDecode(resposta.body) as List;
    return [for (final item in itens) Agendamento.fromJson(item)];
  }

  Future<Agendamento> buscar(String token, int id) async {
    final resposta = await cliente.get(
      Uri.parse('$enderecoDaApi/agendamentos/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resposta.statusCode != 200) {
      throw RecusaDaApi(resposta.statusCode, jsonDecode(resposta.body)['detail']);
    }
    return Agendamento.fromJson(jsonDecode(resposta.body));
  }
}