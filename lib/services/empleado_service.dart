import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/empleado.dart';

class EmpleadoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'empleados';

  // Obtener todos los empleados activos
  Stream<List<Empleado>> getEmpleadosActivos() {
    return _firestore
        .collection(_collection)
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Empleado.fromFirestore(doc)).toList());
  }

  // Obtener un empleado por ID
  Future<Empleado?> getEmpleado(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return Empleado.fromFirestore(doc);
    } catch (e) {
      print('Error obteniendo empleado: $e');
      return null;
    }
  }

  // Crear empleado
  Future<String> crearEmpleado(Empleado empleado) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(empleado.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creando empleado: $e');
      rethrow;
    }
  }

  // Actualizar empleado
  Future<void> actualizarEmpleado(Empleado empleado) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(empleado.id)
          .update(empleado.toFirestore());
    } catch (e) {
      print('Error actualizando empleado: $e');
      rethrow;
    }
  }

  // Desactivar empleado (soft delete)
  Future<void> desactivarEmpleado(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'activo': false,
      });
    } catch (e) {
      print('Error desactivando empleado: $e');
      rethrow;
    }
  }

  // Buscar empleados por nombre
  Future<List<Empleado>> buscarPorNombre(String nombre) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('activo', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => Empleado.fromFirestore(doc))
          .where((empleado) =>
              empleado.nombreCompleto.toLowerCase().contains(nombre.toLowerCase()))
          .toList();
    } catch (e) {
      print('Error buscando empleados: $e');
      return [];
    }
  }

  // Obtener empleados por cargo
  Future<List<Empleado>> getEmpleadosPorCargo(String cargo) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('activo', isEqualTo: true)
          .where('cargo', isEqualTo: cargo)
          .get();

      return snapshot.docs
          .map((doc) => Empleado.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error obteniendo empleados por cargo: $e');
      return [];
    }
  }

  // Obtener total de empleados activos
  Future<int> getTotalEmpleadosActivos() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('activo', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error obteniendo total de empleados: $e');
      return 0;
    }
  }
}
