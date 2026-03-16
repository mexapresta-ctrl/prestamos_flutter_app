class ClienteModel {
  final int id;
  final String nombre;
  final String? telefono;

  ClienteModel({
    required this.id,
    required this.nombre,
    this.telefono,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      telefono: json['telefono'] as String?,
    );
  }
}
