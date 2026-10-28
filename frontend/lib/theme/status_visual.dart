import 'package:flutter/material.dart';
import 'app_theme.dart';

class StatusVisual {
  const StatusVisual(this.cor, this.icone);
  final Color cor;
  final IconData icone;
}

StatusVisual statusVisual(String status) {
  switch (status.trim().toLowerCase()) {
    case 'confirmado':
      return const StatusVisual(Cores.verdeFolha, Icons.check_circle);
    case 'em transporte':
      return const StatusVisual(Cores.terra, Icons.local_shipping);
    case 'concluído':
    case 'concluido':
      return const StatusVisual(Cores.verdeProfundo, Icons.done_all);
    default:
      return const StatusVisual(Cores.douradoEscuro, Icons.schedule);
  }
}