import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

class FirmaDigital {
  final String id;
  final String usuarioId;
  final String nombreUsuario;
  final UserRole rolUsuario;
  final String firmaUrl; // URL de la imagen de la firma en Firebase Storage
  final DateTime fechaFirma;
  final String? comentarios;
  final String? ipAddress;

  FirmaDigital({
    required this.id,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.rolUsuario,
    required this.firmaUrl,
    required this.fechaFirma,
    this.comentarios,
    this.ipAddress,
  });

  factory FirmaDigital.fromFirestore(Map<String, dynamic> data, String id) {
    return FirmaDigital(
      id: id,
      usuarioId: data['usuarioId'] ?? '',
      nombreUsuario: data['nombreUsuario'] ?? '',
      rolUsuario: UserRoleExtension.fromString(data['rolUsuario'] ?? 'empleado'),
      firmaUrl: data['firmaUrl'] ?? '',
      fechaFirma: (data['fechaFirma'] as Timestamp).toDate(),
      comentarios: data['comentarios'],
      ipAddress: data['ipAddress'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'usuarioId': usuarioId,
      'nombreUsuario': nombreUsuario,
      'rolUsuario': rolUsuario.key,
      'firmaUrl': firmaUrl,
      'fechaFirma': Timestamp.fromDate(fechaFirma),
      'comentarios': comentarios,
      'ipAddress': ipAddress,
    };
  }

  FirmaDigital copyWith({
    String? id,
    String? usuarioId,
    String? nombreUsuario,
    UserRole? rolUsuario,
    String? firmaUrl,
    DateTime? fechaFirma,
    String? comentarios,
    String? ipAddress,
  }) {
    return FirmaDigital(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      rolUsuario: rolUsuario ?? this.rolUsuario,
      firmaUrl: firmaUrl ?? this.firmaUrl,
      fechaFirma: fechaFirma ?? this.fechaFirma,
      comentarios: comentarios ?? this.comentarios,
      ipAddress: ipAddress ?? this.ipAddress,
    );
  }
}
