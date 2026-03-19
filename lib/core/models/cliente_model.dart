class ClienteModel {
  final String id;
  final String nombre;
  final String? telefono;

  ClienteModel({required this.id, required this.nombre, this.telefono});

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: (json['id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      telefono: json['telefono']?.toString(),
    );
  }
}
