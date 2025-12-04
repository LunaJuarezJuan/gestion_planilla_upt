class DetallePlanilla {
  final String id;
  final String empleadoId;
  final String nombreEmpleado;
  final String empleadoEmail;
  final double salarioBase;
  final int horasTrabajadas;
  final double montoHoras;
  final Map<String, double> deducciones; // tipo -> monto
  final Map<String, double> bonificaciones; // tipo -> monto
  final double totalDeducciones;
  final double totalBonificaciones;
  final double netoAPagar;
  final double sueldoBruto;

  DetallePlanilla({
    required this.id,
    required this.empleadoId,
    required this.nombreEmpleado,
    required this.empleadoEmail,
    required this.salarioBase,
    required this.horasTrabajadas,
    required this.montoHoras,
    required this.deducciones,
    required this.bonificaciones,
    required this.totalDeducciones,
    required this.totalBonificaciones,
    required this.netoAPagar,
    required this.sueldoBruto,
  });

  factory DetallePlanilla.fromFirestore(Map<String, dynamic> data, String id) {
    return DetallePlanilla(
      id: id,
      empleadoId: data['empleadoId'] ?? '',
      nombreEmpleado: data['nombreEmpleado'] ?? '',
      empleadoEmail: data['empleadoEmail'] ?? '',
      salarioBase: (data['salarioBase'] ?? 0).toDouble(),
      horasTrabajadas: data['horasTrabajadas'] ?? 0,
      montoHoras: (data['montoHoras'] ?? 0).toDouble(),
      deducciones: Map<String, double>.from(
        (data['deducciones'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            ) ??
            {},
      ),
      bonificaciones: Map<String, double>.from(
        (data['bonificaciones'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            ) ??
            {},
      ),
      totalDeducciones: (data['totalDeducciones'] ?? 0).toDouble(),
      totalBonificaciones: (data['totalBonificaciones'] ?? 0).toDouble(),
      netoAPagar: (data['netoAPagar'] ?? 0).toDouble(),
      sueldoBruto: (data['sueldoBruto'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'empleadoId': empleadoId,
      'nombreEmpleado': nombreEmpleado,
      'empleadoEmail': empleadoEmail,
      'salarioBase': salarioBase,
      'horasTrabajadas': horasTrabajadas,
      'montoHoras': montoHoras,
      'deducciones': deducciones,
      'bonificaciones': bonificaciones,
      'totalDeducciones': totalDeducciones,
      'totalBonificaciones': totalBonificaciones,
      'netoAPagar': netoAPagar,
      'sueldoBruto': sueldoBruto,
    };
  }

  DetallePlanilla copyWith({
    String? id,
    String? empleadoId,
    String? nombreEmpleado,
    String? empleadoEmail,
    double? salarioBase,
    int? horasTrabajadas,
    double? montoHoras,
    Map<String, double>? deducciones,
    Map<String, double>? bonificaciones,
    double? totalDeducciones,
    double? totalBonificaciones,
    double? netoAPagar,
    double? sueldoBruto,
  }) {
    return DetallePlanilla(
      id: id ?? this.id,
      empleadoId: empleadoId ?? this.empleadoId,
      nombreEmpleado: nombreEmpleado ?? this.nombreEmpleado,
      empleadoEmail: empleadoEmail ?? this.empleadoEmail,
      salarioBase: salarioBase ?? this.salarioBase,
      horasTrabajadas: horasTrabajadas ?? this.horasTrabajadas,
      montoHoras: montoHoras ?? this.montoHoras,
      deducciones: deducciones ?? this.deducciones,
      bonificaciones: bonificaciones ?? this.bonificaciones,
      totalDeducciones: totalDeducciones ?? this.totalDeducciones,
      totalBonificaciones: totalBonificaciones ?? this.totalBonificaciones,
      netoAPagar: netoAPagar ?? this.netoAPagar,
      sueldoBruto: sueldoBruto ?? this.sueldoBruto,
    );
  }
}
