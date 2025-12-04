import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/planilla.dart';
import '../models/firma_digital.dart';
import '../models/user_role.dart';
import '../models/planilla_estado.dart';
import '../services/planilla_service.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../widgets/firma_widget.dart';

class RevisarPlanillaScreen extends StatefulWidget {
  final String planillaId;

  const RevisarPlanillaScreen({
    Key? key,
    required this.planillaId,
  }) : super(key: key);

  @override
  State<RevisarPlanillaScreen> createState() => _RevisarPlanillaScreenState();
}

class _RevisarPlanillaScreenState extends State<RevisarPlanillaScreen> {
  final PlanillaService _planillaService = PlanillaService();
  final StorageService _storageService = StorageService();
  final TextEditingController _comentariosController = TextEditingController();

  Uint8List? _firmaCapturada;
  bool _isLoading = false;

  @override
  void dispose() {
    _comentariosController.dispose();
    super.dispose();
  }

  Future<void> _firmarPlanilla(Planilla planilla) async {
    if (_firmaCapturada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe capturar su firma primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      // final notificationService = Provider.of<NotificationService>(context, listen: false);
      final usuario = await authService.getCurrentUserData();

      if (usuario == null) {
        throw Exception('Usuario no autenticado');
      }

      // Subir firma a Storage
      final firmaUrl = await _storageService.subirFirma(
        firmaBytes: _firmaCapturada!,
        usuarioId: usuario.id,
        planillaId: widget.planillaId,
      );

      // Crear objeto de firma
      final firma = FirmaDigital(
        id: usuario.rol.key,
        usuarioId: usuario.id,
        nombreUsuario: usuario.nombreCompleto,
        rolUsuario: usuario.rol,
        firmaUrl: firmaUrl,
        fechaFirma: DateTime.now(),
        comentarios: _comentariosController.text.isNotEmpty
            ? _comentariosController.text
            : null,
      );

      // Agregar firma a la planilla
      await _planillaService.agregarFirma(
        planillaId: widget.planillaId,
        rolKey: usuario.rol.key,
        firma: firma,
      );

      // Actualizar estado según el rol
      PlanillaEstado nuevoEstado;
      switch (usuario.rol) {
        case UserRole.rrhh:
          nuevoEstado = PlanillaEstado.pendienteGerenteFinanciero;
          break;
        case UserRole.gerenteFinanciero:
          nuevoEstado = PlanillaEstado.pendienteGerenteGeneral;
          break;
        case UserRole.gerenteGeneral:
          nuevoEstado = PlanillaEstado.pendienteTesoreria;
          break;
        case UserRole.tesoreria:
          nuevoEstado = PlanillaEstado.pendienteContabilidad;
          break;
        case UserRole.contabilidad:
          nuevoEstado = PlanillaEstado.completada;
          break;
        default:
          nuevoEstado = planilla.estado;
      }

      await _planillaService.actualizarEstado(widget.planillaId, nuevoEstado);

      // Enviar notificaciones (implementar según el siguiente responsable)
      // await notificationService.notificarFirmaPlanilla(...);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Firma registrada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al firmar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rechazarPlanilla(Planilla planilla) async {
    final motivo = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Rechazar Planilla'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Motivo del rechazo',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Rechazar'),
            ),
          ],
        );
      },
    );

    if (motivo == null || motivo.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _planillaService.rechazarPlanilla(
        planillaId: widget.planillaId,
        motivo: motivo,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Planilla rechazada'),
            backgroundColor: Colors.orange,
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al rechazar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisar Planilla'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<Planilla?>(
        stream: _planillaService.getPlanillaStream(widget.planillaId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Planilla no encontrada'));
          }

          final planilla = snapshot.data!;

          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Información de la planilla
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Planilla de ${planilla.mes}',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text('Empleados: ${planilla.cantidadEmpleados}'),
                              Text(
                                'Monto Total: ${NumberFormat.currency(symbol: 'S/. ', decimalDigits: 2).format(planilla.montoTotal)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text('Estado: ${planilla.estado.displayName}'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Detalles de empleados
                      Card(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              color: Colors.blue.shade700,
                              child: const Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Detalles por Empleado',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: planilla.detalles.length,
                              itemBuilder: (context, index) {
                                final detalle = planilla.detalles[index];
                                return ListTile(
                                  title: Text(detalle.nombreEmpleado),
                                  subtitle: Text(
                                    'Horas: ${detalle.horasTrabajadas} hrs',
                                  ),
                                  trailing: Text(
                                    NumberFormat.currency(
                                      symbol: 'S/. ',
                                      decimalDigits: 2,
                                    ).format(detalle.netoAPagar),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Campo de comentarios
                      TextField(
                        controller: _comentariosController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Comentarios (opcional)',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Widget de firma
                      FirmaWidget(
                        titulo: 'Capturar Firma Digital',
                        onFirmaCaptured: (firma) {
                          setState(() {
                            _firmaCapturada = firma;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Botones de acción
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _rechazarPlanilla(planilla),
                              icon: const Icon(Icons.cancel),
                              label: const Text('Rechazar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _firmarPlanilla(planilla),
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Aprobar y Firmar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
