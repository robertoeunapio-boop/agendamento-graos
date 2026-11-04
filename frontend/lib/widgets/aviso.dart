import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

void avisar(BuildContext context, String texto, {bool erro = false}) {
  final mensageiro = ScaffoldMessenger.of(context);
  mensageiro.hideCurrentSnackBar();
  mensageiro.showSnackBar(
    SnackBar(
      content: Text(texto),
      backgroundColor: erro ? Cores.perigo : Cores.verdeFolha,
    ),
  );
}