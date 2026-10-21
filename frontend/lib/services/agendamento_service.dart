import '../models/agendamento.dart';
import '../repositories/agendamento_repository.dart';
import '../repositories/usuario_repository.dart';
import 'sessao_service.dart';

class ErroDeAgendamentos implements Exception {
  ErroDeAgendamentos(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

class AgendamentoService {
  AgendamentoService(this.repositorio, this.sessao);
  final AgendamentoRepository repositorio;
  final SessaoService sessao;

  Future<List<Agendamento>> listar() async {
    try {
      return await repositorio.listar(sessao.token!);
    } on RecusaDaApi catch (e) {
      throw ErroDeAgendamentos(e.mensagem);
    } on Exception {
      throw ErroDeAgendamentos('Não consegui falar com a API. O uvicorn está rodando?');
    }
  }

  Future<Agendamento> buscar(int id) async {
    try {
      return await repositorio.buscar(sessao.token!, id);
    } on RecusaDaApi catch (e) {
      throw ErroDeAgendamentos(e.mensagem);
    } on Exception {
      throw ErroDeAgendamentos('Não consegui falar com a API. O uvicorn está rodando?');
    }
  }
}