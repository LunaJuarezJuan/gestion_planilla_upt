import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Subir firma digital
  Future<String> subirFirma({
    required Uint8List firmaBytes,
    required String usuarioId,
    required String planillaId,
  }) async {
    try {
      final String fileName = '${_uuid.v4()}.png';
      final String path = 'firmas/$planillaId/$usuarioId/$fileName';
      
      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putData(
        firmaBytes,
        SettableMetadata(contentType: 'image/png'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error subiendo firma: $e');
      rethrow;
    }
  }

  // Subir comprobante de pago
  Future<String> subirComprobante({
    required File archivo,
    required String planillaId,
  }) async {
    try {
      final String fileName = '${_uuid.v4()}_${archivo.path.split('/').last}';
      final String path = 'comprobantes/$planillaId/$fileName';
      
      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putFile(archivo);

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error subiendo comprobante: $e');
      rethrow;
    }
  }

  // Subir PDF de planilla
  Future<String> subirPDF({
    required Uint8List pdfBytes,
    required String planillaId,
  }) async {
    try {
      final String fileName = 'planilla_$planillaId.pdf';
      final String path = 'planillas/$planillaId/$fileName';
      
      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putData(
        pdfBytes,
        SettableMetadata(contentType: 'application/pdf'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error subiendo PDF: $e');
      rethrow;
    }
  }

  // Eliminar archivo
  Future<void> eliminarArchivo(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('Error eliminando archivo: $e');
      rethrow;
    }
  }

  // Descargar archivo como bytes
  Future<Uint8List?> descargarArchivo(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      final Uint8List? data = await ref.getData();
      return data;
    } catch (e) {
      print('Error descargando archivo: $e');
      return null;
    }
  }

  // Obtener metadata de archivo
  Future<FullMetadata?> getMetadata(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      return await ref.getMetadata();
    } catch (e) {
      print('Error obteniendo metadata: $e');
      return null;
    }
  }
}
