import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario.dart';
import '../models/user_role.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream de usuario autenticado
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Obtener datos del usuario actual
  Future<Usuario?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (!doc.exists) return null;

      return Usuario.fromFirestore(doc);
    } catch (e) {
      print('Error obteniendo datos del usuario: $e');
      return null;
    }
  }

  // Iniciar sesión
  Future<Usuario?> signIn(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) return null;

      return await getCurrentUserData();
    } catch (e) {
      print('Error en inicio de sesión: $e');
      rethrow;
    }
  }

  // Registrar usuario
  Future<Usuario?> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required UserRole rol,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) return null;

      // Crear documento de usuario
      final usuario = Usuario(
        id: result.user!.uid,
        email: email,
        nombre: nombre,
        apellido: apellido,
        rol: rol,
        fechaCreacion: DateTime.now(),
      );

      await _firestore
          .collection('usuarios')
          .doc(result.user!.uid)
          .set(usuario.toFirestore());

      return usuario;
    } catch (e) {
      print('Error en registro: $e');
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Actualizar perfil de usuario
  Future<void> updateUserProfile({
    required String userId,
    String? nombre,
    String? apellido,
  }) async {
    final Map<String, dynamic> updates = {};

    if (nombre != null) updates['nombre'] = nombre;
    if (apellido != null) updates['apellido'] = apellido;

    if (updates.isNotEmpty) {
      await _firestore.collection('usuarios').doc(userId).update(updates);
    }
  }

  // Verificar rol del usuario
  Future<bool> hasRole(UserRole requiredRole) async {
    final userData = await getCurrentUserData();
    return userData?.rol == requiredRole;
  }

  // Verificar si el usuario tiene uno de varios roles
  Future<bool> hasAnyRole(List<UserRole> roles) async {
    final userData = await getCurrentUserData();
    return userData != null && roles.contains(userData.rol);
  }
}
