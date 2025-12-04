import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/crear_planilla_screen.dart';
import 'screens/mis_boletas_screen.dart';
import 'screens/historial_pagos_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar formatos de fecha en español
  await initializeDateFormatting('es', null);
  
  // Inicializar Firebase con las opciones generadas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<NotificationService>(
          create: (_) {
            final service = NotificationService();
            service.initialize();
            return service;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Gestión de Planilla UPT',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/crear-planilla': (context) => const CrearPlanillaScreen(),
          '/mis-boletas': (context) => const MisBoletasScreen(),
          '/historial-pagos': (context) => const HistorialPagosScreen(),
          '/listar-planillas': (context) => const MisBoletasScreen(),
          '/empleados': (context) => const MisBoletasScreen(),
          '/pendientes-rrhh': (context) => const MisBoletasScreen(),
          '/pendientes-gerente': (context) => const MisBoletasScreen(),
          '/reportes': (context) => const MisBoletasScreen(),
          '/pendientes-tesoreria': (context) => const MisBoletasScreen(),
          '/pagos-realizados': (context) => const MisBoletasScreen(),
          '/subir-comprobantes': (context) => const MisBoletasScreen(),
          '/pendientes-contabilidad': (context) => const MisBoletasScreen(),
          '/registros-contables': (context) => const MisBoletasScreen(),
        },
      ),
    );
  }
}
