class Agendamento {
  final int id;
  final String produtor;
  final String tipoGrao;
  final double quantidadeToneladas;
  final String status;
  final int? donoId;

  Agendamento({
    required this.id,
    required this.produtor,
    required this.tipoGrao,
    required this.quantidadeToneladas,
    required this.status,
    this.donoId,
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'],
      produtor: json['produtor'],
      tipoGrao: json['tipo_grao'],
      quantidadeToneladas: (json['quantidade_toneladas'] as num).toDouble(),
      status: json['status'],
      donoId: json['dono_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'produtor': produtor,
      'tipo_grao': tipoGrao,
      'quantidade_toneladas': quantidadeToneladas,
      'status': status,
      if (donoId != null) 'dono_id': donoId,
    };
  }
}