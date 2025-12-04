import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

class Usuario {
  final String id;
  final String email;
  final String nombre;
  final String apellido;
  final UserRole rol;
  final DateTime fechaCreacion;
  final bool activo;

  Usuario({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.rol,
    required this.fechaCreacion,
    this.activo = true,
  });

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Usuario(
      id: doc.id,
      email: data['email'] ?? '',
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      rol: UserRoleExtension.fromString(data['rol'] ?? 'empleado'),
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
      activo: data['activo'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'rol': rol.key,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'activo': activo,
    };
  }

  String get nombreCompleto => '$nombre $apellido';

  Usuario copyWith({
    String? id,
    String? email,
    String? nombre,
    String? apellido,
    UserRole? rol,
    DateTime? fechaCreacion,
    bool? activo,
  }) {
    return Usuario(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      rol: rol ?? this.rol,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      activo: activo ?? this.activo,
    );
  }
}
