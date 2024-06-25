import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Saldo {
  final int id;
  final double saldo;

  Saldo({
    required this.id,
    required this.saldo,
  });

  factory Saldo.fromSqfliteDatabase(Map<String, dynamic> map) => Saldo(
    id: map['id']?.toInt() ?? 0,
    saldo: map['saldo'] ?? 0,
  );
}