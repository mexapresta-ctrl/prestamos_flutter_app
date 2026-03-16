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
    return UserModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      usuario: json['usuario'] as String,
      rol: json['rol'] as String,
      activo: json['activo'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
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
