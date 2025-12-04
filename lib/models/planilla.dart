import 'package:cloud_firestore/cloud_firestore.dart';
import 'planilla_estado.dart';
import 'detalle_planilla.dart';
import 'firma_digital.dart';

class Planilla {
  final String id;
  final String mes; // Formato: "2024-12"
  final int anio;
  final int mesNumero;
  final DateTime fechaCreacion;
  final PlanillaEstado estado;
  final List<DetallePlanilla> detalles;
  final Map<String, FirmaDigital> firmas; // rol -> firma
  final double montoTotal;
  final String? pdfUrl;
  final List<String> comprobantesUrls;
  final String? motivoRechazo;
  final DateTime? fechaCompletado;

  Planilla({
    required this.id,
    required this.mes,
    required this.anio,
    required this.mesNumero,
    required this.fechaCreacion,
    required this.estado,
    required this.detalles,
    required this.firmas,
    required this.montoTotal,
    this.pdfUrl,
    this.comprobantesUrls = const [],
    this.motivoRechazo,
    this.fechaCompletado,
  });

  factory Planilla.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Parse detalles
    List<DetallePlanilla> detalles = [];
    if (data['detalles'] != null) {
      detalles = (data['detalles'] as List)
          .asMap()
          .entries
          .map((entry) => DetallePlanilla.fromFirestore(
                entry.value as Map<String, dynamic>,
                entry.key.toString(),
              ))
          .toList();
    }

    // Parse firmas
    Map<String, FirmaDigital> firmas = {};
    if (data['firmas'] != null) {
      (data['firmas'] as Map<String, dynamic>).forEach((key, value) {
        firmas[key] = FirmaDigital.fromFirestore(
          value as Map<String, dynamic>,
          key,
        );
      });
    }

    return Planilla(
      id: doc.id,
      mes: data['mes'] ?? '',
      anio: data['anio'] ?? DateTime.now().year,
      mesNumero: data['mesNumero'] ?? DateTime.now().month,
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
      estado: PlanillaEstadoExtension.fromString(data['estado'] ?? 'en_calculo'),
      detalles: detalles,
      firmas: firmas,
      montoTotal: (data['montoTotal'] ?? 0).toDouble(),
      pdfUrl: data['pdfUrl'],
      comprobantesUrls: List<String>.from(data['comprobantesUrls'] ?? []),
      motivoRechazo: data['motivoRechazo'],
      fechaCompletado: data['fechaCompletado'] != null
          ? (data['fechaCompletado'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mes': mes,
      'anio': anio,
      'mesNumero': mesNumero,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'estado': estado.key,
      'detalles': detalles.map((d) => d.toFirestore()).toList(),
      'firmas': firmas.map((key, value) => MapEntry(key, value.toFirestore())),
      'montoTotal': montoTotal,
      'pdfUrl': pdfUrl,
      'comprobantesUrls': comprobantesUrls,
      'motivoRechazo': motivoRechazo,
      'fechaCompletado':
          fechaCompletado != null ? Timestamp.fromDate(fechaCompletado!) : null,
    };
  }

  bool tieneFirma(String rolKey) {
    return firmas.containsKey(rolKey);
  }

  int get cantidadEmpleados => detalles.length;

  Planilla copyWith({
    String? id,
    String? mes,
    int? anio,
    int? mesNumero,
    DateTime? fechaCreacion,
    PlanillaEstado? estado,
    List<DetallePlanilla>? detalles,
    Map<String, FirmaDigital>? firmas,
    double? montoTotal,
    String? pdfUrl,
    List<String>? comprobantesUrls,
    String? motivoRechazo,
    DateTime? fechaCompletado,
  }) {
    return Planilla(
      id: id ?? this.id,
      mes: mes ?? this.mes,
      anio: anio ?? this.anio,
      mesNumero: mesNumero ?? this.mesNumero,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      estado: estado ?? this.estado,
      detalles: detalles ?? this.detalles,
      firmas: firmas ?? this.firmas,
      montoTotal: montoTotal ?? this.montoTotal,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      comprobantesUrls: comprobantesUrls ?? this.comprobantesUrls,
      motivoRechazo: motivoRechazo ?? this.motivoRechazo,
      fechaCompletado: fechaCompletado ?? this.fechaCompletado,
    );
  }
}
