import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    // Solicitar permisos
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configurar notificaciones locales
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings);

    // Obtener token FCM
    final token = await _fcm.getToken();
    print('FCM Token: $token');

    // Manejar mensajes en primer plano
    FirebaseMessaging.onMessage.listen(_handleMessage);

    // Manejar mensajes cuando la app se abre desde una notificación
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  void _handleMessage(RemoteMessage message) {
    print('Mensaje recibido: ${message.notification?.title}');
    
    if (message.notification != null) {
      _mostrarNotificacionLocal(
        titulo: message.notification!.title ?? 'Notificación',
        cuerpo: message.notification!.body ?? '',
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Notificación abierta: ${message.notification?.title}');
    // Aquí puedes navegar a una pantalla específica
  }

  Future<void> _mostrarNotificacionLocal({
    required String titulo,
    required String cuerpo,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'planilla_channel',
      'Notificaciones de Planilla',
      channelDescription: 'Notificaciones del sistema de planilla',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      titulo,
      cuerpo,
      details,
    );
  }

  // Guardar token del usuario
  Future<void> guardarTokenUsuario(String userId) async {
    final token = await _fcm.getToken();
    if (token != null) {
      await _firestore.collection('usuarios').doc(userId).update({
        'fcmToken': token,
      });
    }
  }

  // Enviar notificación a usuario específico
  Future<void> enviarNotificacionAUsuario({
    required String userId,
    required String titulo,
    required String mensaje,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('notificaciones').add({
        'userId': userId,
        'titulo': titulo,
        'mensaje': mensaje,
        'data': data ?? {},
        'leida': false,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      // Mostrar notificación local
      await _mostrarNotificacionLocal(titulo: titulo, cuerpo: mensaje);
    } catch (e) {
      print('Error enviando notificación: $e');
    }
  }

  // Enviar notificación a múltiples usuarios
  Future<void> enviarNotificacionMasiva({
    required List<String> userIds,
    required String titulo,
    required String mensaje,
    Map<String, dynamic>? data,
  }) async {
    for (final userId in userIds) {
      await enviarNotificacionAUsuario(
        userId: userId,
        titulo: titulo,
        mensaje: mensaje,
        data: data,
      );
    }
  }

  // Notificar firma de planilla
  Future<void> notificarFirmaPlanilla({
    required String planillaId,
    required String mes,
    required String firmante,
    required String siguienteResponsable,
  }) async {
    await enviarNotificacionAUsuario(
      userId: siguienteResponsable,
      titulo: 'Planilla pendiente de revisión',
      mensaje: '$firmante ha firmado la planilla de $mes. Requiere tu aprobación.',
      data: {
        'tipo': 'firma_planilla',
        'planillaId': planillaId,
      },
    );
  }

  // Notificar rechazo de planilla
  Future<void> notificarRechazo({
    required String planillaId,
    required String mes,
    required String motivo,
    required List<String> destinatarios,
  }) async {
    await enviarNotificacionMasiva(
      userIds: destinatarios,
      titulo: 'Planilla rechazada',
      mensaje: 'La planilla de $mes ha sido rechazada. Motivo: $motivo',
      data: {
        'tipo': 'rechazo_planilla',
        'planillaId': planillaId,
      },
    );
  }

  // Notificar pago completado
  Future<void> notificarPagoCompletado({
    required String empleadoId,
    required String mes,
    required double monto,
  }) async {
    await enviarNotificacionAUsuario(
      userId: empleadoId,
      titulo: 'Pago procesado',
      mensaje: 'Tu pago de planilla de $mes por S/. ${monto.toStringAsFixed(2)} ha sido procesado.',
      data: {
        'tipo': 'pago_completado',
      },
    );
  }

  // Notificar planilla completada
  Future<void> notificarPlanillaCompletada({
    required String planillaId,
    required String mes,
    required List<String> todoLosInvolucrados,
  }) async {
    await enviarNotificacionMasiva(
      userIds: todoLosInvolucrados,
      titulo: 'Planilla completada',
      mensaje: 'La planilla de $mes ha sido completada exitosamente.',
      data: {
        'tipo': 'planilla_completada',
        'planillaId': planillaId,
      },
    );
  }

  // Obtener notificaciones del usuario
  Stream<List<Map<String, dynamic>>> getNotificacionesUsuario(String userId) {
    return _firestore
        .collection('notificaciones')
        .where('userId', isEqualTo: userId)
        .orderBy('fechaCreacion', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // Marcar notificación como leída
  Future<void> marcarComoLeida(String notificacionId) async {
    await _firestore
        .collection('notificaciones')
        .doc(notificacionId)
        .update({'leida': true});
  }
}
