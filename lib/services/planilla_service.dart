import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/planilla.dart';
import '../models/planilla_estado.dart';
import '../models/detalle_planilla.dart';
import '../models/firma_digital.dart';

class PlanillaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'planillas';

  // Crear nueva planilla
  Future<String> crearPlanilla(Planilla planilla) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(planilla.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creando planilla: $e');
      rethrow;
    }
  }

  // Obtener planilla por ID
  Future<Planilla?> getPlanilla(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return Planilla.fromFirestore(doc);
    } catch (e) {
      print('Error obteniendo planilla: $e');
      return null;
    }
  }

  // Stream de planilla por ID
  Stream<Planilla?> getPlanillaStream(String id) {
    return _firestore
        .collection(_collection)
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? Planilla.fromFirestore(doc) : null);
  }

  // Obtener planillas por estado
  Stream<List<Planilla>> getPlanillasPorEstado(PlanillaEstado estado) {
    return _firestore
        .collection(_collection)
        .where('estado', isEqualTo: estado.key)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Planilla.fromFirestore(doc)).toList());
  }

  // Obtener todas las planillas
  Stream<List<Planilla>> getAllPlanillas() {
    return _firestore
        .collection(_collection)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Planilla.fromFirestore(doc)).toList());
  }

  // Obtener planillas del año
  Stream<List<Planilla>> getPlanillasPorAnio(int anio) {
    return _firestore
        .collection(_collection)
        .where('anio', isEqualTo: anio)
        .orderBy('mesNumero', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Planilla.fromFirestore(doc)).toList());
  }

  // Actualizar estado de planilla
  Future<void> actualizarEstado(String planillaId, PlanillaEstado nuevoEstado) async {
    try {
      await _firestore.collection(_collection).doc(planillaId).update({
        'estado': nuevoEstado.key,
      });
    } catch (e) {
      print('Error actualizando estado: $e');
      rethrow;
    }
  }

  // Agregar firma a planilla
  Future<void> agregarFirma({
    required String planillaId,
    required String rolKey,
    required FirmaDigital firma,
  }) async {
    try {
      await _firestore.collection(_collection).doc(planillaId).update({
        'firmas.$rolKey': firma.toFirestore(),
      });
    } catch (e) {
      print('Error agregando firma: $e');
      rethrow;
    }
  }

  // Actualizar detalles de planilla
  Future<void> actualizarDetalles({
    required String planillaId,
    required List<DetallePlanilla> detalles,
    required double montoTotal,
  }) async {
    try {
      await _firestore.collection(_collection).doc(planillaId).update({
        'detalles': detalles.map((d) => d.toFirestore()).toList(),
        'montoTotal': montoTotal,
      });
    } catch (e) {
      print('Error actualizando detalles: $e');
      rethrow;
    }
  }

  // Rechazar planilla
  Future<void> rechazarPlanilla({
    required String planillaId,
    required String motivo,
  }) async {
    try {
      await _firestore.collection(_collection).doc(planillaId).update({
        'estado': PlanillaEstado.rechazada.key,
        'motivoRechazo': motivo,
      });
    } catch (e) {
      print('Error rechazando planilla: $e');
      rethrow;
    }
  }

  // Marcar planilla como completada
  Future<void> completarPlanilla({
    required String planillaId,
    required String pdfUrl,
  }) async {
    try {
      await _firestore.collection(_collection).doc(planillaId).update({
        'estado': PlanillaEstado.completada.key,
        'fechaCompletado': FieldValue.serverTimestamp(),
        'pdfUrl': pdfUrl,
      });
    } catch (e) {
      print('Error completando planilla: $e');
      rethrow;
    }
  }

  // Agregar comprobante de pago
  Future<void> agregarComprobante({
    required String planillaId,
    required String comprobanteUrl,
  }) async {
    try {
      await _firestore.collection(_collection).doc(planillaId).update({
        'comprobantesUrls': FieldValue.arrayUnion([comprobanteUrl]),
      });
    } catch (e) {
      print('Error agregando comprobante: $e');
      rethrow;
    }
  }

  // Verificar si existe planilla para mes/año
  Future<bool> existePlanilla(int anio, int mes) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('anio', isEqualTo: anio)
          .where('mesNumero', isEqualTo: mes)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error verificando planilla existente: $e');
      return false;
    }
  }

  // Obtener planilla por mes/año
  Future<Planilla?> getPlanillaPorMesAnio(int anio, int mes) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('anio', isEqualTo: anio)
          .where('mesNumero', isEqualTo: mes)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      return Planilla.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error obteniendo planilla por mes/año: $e');
      return null;
    }
  }

  // Obtener todas las planillas (alias para getAllPlanillas)
  Stream<List<Planilla>> obtenerTodasPlanillas() {
    return getAllPlanillas();
  }

  // Obtener planillas completadas
  Stream<List<Planilla>> obtenerPlanillasCompletadas() {
    return getPlanillasPorEstado(PlanillaEstado.completada);
  }

  // Obtener detalle de planilla por email de empleado
  Future<DetallePlanilla?> obtenerDetallePorEmpleadoEmail(
    String planillaId,
    String emailEmpleado,
  ) async {
    try {
      final planilla = await getPlanilla(planillaId);
      if (planilla == null) return null;

      // Buscar el detalle que corresponde al empleado
      for (final detalle in planilla.detalles) {
        if (detalle.empleadoEmail == emailEmpleado) {
          return detalle;
        }
      }

      return null;
    } catch (e) {
      print('Error obteniendo detalle por empleado: $e');
      return null;
    }
  }
}
