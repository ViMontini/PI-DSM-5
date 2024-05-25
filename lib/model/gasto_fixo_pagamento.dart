class GF_Pagamentos{
  final int id;
  final int gf_id;
  final String data_pag;

  GF_Pagamentos({
    required this.id,
    required this.gf_id,
    required this.data_pag,
  });

  factory GF_Pagamentos.fromSqfliteDatabase(Map<String, dynamic> map) => GF_Pagamentos(
    id: map['id']?.toInt() ?? 0,
    gf_id: map['gf_id'] ?? 0,
    data_pag: map['data_pag'] ?? '',
  );
}