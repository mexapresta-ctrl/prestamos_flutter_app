class UserModel {
  final String id;
  final String nombre;
  final String usuario;
  final String rol;
  final bool activo;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.nombre,
    required this.usuario,
    required this.rol,
    required this.activo,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    bool safeBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true';
      return true;
    }

    return UserModel(
      id: (json['id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      usuario: (json['usuario'] ?? '').toString(),
      rol: (json['rol'] ?? '').toString(),
      activo: safeBool(json['activo']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'usuario': usuario,
      'rol': rol,
      'activo': activo,
    };
  }
}
