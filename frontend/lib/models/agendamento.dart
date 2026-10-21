class Agendamento {
  Agendamento({
    required this.id,
    required this.produtor,
    required this.tipoGrao,
    required this.quantidadeToneladas,
    required this.status,
  });

  final int id;
  final String produtor;
  final String tipoGrao;
  final double quantidadeToneladas;
  final String status;

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'],
      produtor: json['produtor'],
      tipoGrao: json['tipo_grao'],
      quantidadeToneladas: (json['quantidade_toneladas'] as num).toDouble(),
      status: json['status'],
    );
  }
}