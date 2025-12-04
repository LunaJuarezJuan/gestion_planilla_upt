import 'package:cloud_firestore/cloud_firestore.dart';

class Empleado {
  final String id;
  final String nombre;
  final String apellido;
  final String dni;
  final String cargo;
  final double salarioBase;
  final String numeroCuenta;
  final String banco;
  final DateTime fechaIngreso;
  final bool activo;
  final String? email;

  Empleado({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.dni,
    required this.cargo,
    required this.salarioBase,
    required this.numeroCuenta,
    required this.banco,
    required this.fechaIngreso,
    this.activo = true,
    this.email,
  });

  factory Empleado.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Empleado(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      dni: data['dni'] ?? '',
      cargo: data['cargo'] ?? '',
      salarioBase: (data['salarioBase'] ?? 0).toDouble(),
      numeroCuenta: data['numeroCuenta'] ?? '',
      banco: data['banco'] ?? '',
      fechaIngreso: (data['fechaIngreso'] as Timestamp).toDate(),
      activo: data['activo'] ?? true,
      email: data['email'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'dni': dni,
      'cargo': cargo,
      'salarioBase': salarioBase,
      'numeroCuenta': numeroCuenta,
      'banco': banco,
      'fechaIngreso': Timestamp.fromDate(fechaIngreso),
      'activo': activo,
      'email': email,
    };
  }

  String get nombreCompleto => '$nombre $apellido';

  Empleado copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? dni,
    String? cargo,
    double? salarioBase,
    String? numeroCuenta,
    String? banco,
    DateTime? fechaIngreso,
    bool? activo,
    String? email,
  }) {
    return Empleado(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      dni: dni ?? this.dni,
      cargo: cargo ?? this.cargo,
      salarioBase: salarioBase ?? this.salarioBase,
      numeroCuenta: numeroCuenta ?? this.numeroCuenta,
      banco: banco ?? this.banco,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      activo: activo ?? this.activo,
      email: email ?? this.email,
    );
  }
}
