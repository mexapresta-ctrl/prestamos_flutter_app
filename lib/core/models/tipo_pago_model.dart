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
    // Handling SQLite boolean mapping (1 = true, 0 = false) if necessary
    // Supabase native booleans will just be boolean
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      return false;
    }

    int safeInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return TipoPagoModel(
      id: safeInt(json['id']),
      nombre: json['nombre'] as String,
      afectaSaldo: parseBool(json['afectaSaldo']),
      activo: parseBool(json['activo']),
    );
  }
}
