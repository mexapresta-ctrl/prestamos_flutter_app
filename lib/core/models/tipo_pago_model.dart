class TipoPagoModel {
  final int id;
  final String nombre;
  final bool afectaSaldo;
  final bool activo;

  TipoPagoModel({
    required this.id,
    required this.nombre,
    required this.afectaSaldo,
    required this.activo,
  });

  factory TipoPagoModel.fromJson(Map<String, dynamic> json) {
    int safeInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    bool safeBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true';
      return false;
    }

    return TipoPagoModel(
      id: safeInt(json['id']),
      nombre: (json['nombre'] ?? '').toString(),
      afectaSaldo: safeBool(json['afectaSaldo'] ?? json['afecta_saldo']),
      activo: safeBool(json['activo']),
    );
  }
}
