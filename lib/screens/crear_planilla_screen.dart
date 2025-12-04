import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/empleado.dart';
import '../models/planilla.dart';
import '../models/detalle_planilla.dart';
import '../models/planilla_estado.dart';
import '../services/empleado_service.dart';
import '../services/planilla_calculo_service.dart';
import '../services/planilla_service.dart';

class CrearPlanillaScreen extends StatefulWidget {
  const CrearPlanillaScreen({Key? key}) : super(key: key);

  @override
  State<CrearPlanillaScreen> createState() => _CrearPlanillaScreenState();
}

class _CrearPlanillaScreenState extends State<CrearPlanillaScreen> {
  final EmpleadoService _empleadoService = EmpleadoService();
  final PlanillaCalculoService _calculoService = PlanillaCalculoService();
  final PlanillaService _planillaService = PlanillaService();

  DateTime _selectedDate = DateTime.now();
  List<Empleado> _empleados = [];
  List<DetallePlanilla> _detalles = [];
  bool _isLoading = false;
  bool _isCalculated = false;

  @override
  void initState() {
    super.initState();
    _loadEmpleados();
  }

  Future<void> _loadEmpleados() async {
    setState(() {
      _isLoading = true;
    });

    _empleadoService.getEmpleadosActivos().listen((empleados) {
      if (mounted) {
        setState(() {
          _empleados = empleados;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _calcularPlanilla() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final detalles = await _calculoService.calcularPlanillaCompleta(
        empleados: _empleados,
        anio: _selectedDate.year,
        mes: _selectedDate.month,
      );

      setState(() {
        _detalles = detalles;
        _isCalculated = true;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Planilla calculada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al calcular planilla: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _guardarPlanilla() async {
    if (!_isCalculated || _detalles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe calcular la planilla primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Verificar si ya existe planilla para este mes
    final existe = await _planillaService.existePlanilla(
      _selectedDate.year,
      _selectedDate.month,
    );

    if (existe) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya existe una planilla para este mes'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final montoTotal = _detalles.fold(0.0, (sum, d) => sum + d.netoAPagar);
      final mesFormato = DateFormat('yyyy-MM').format(_selectedDate);

      final planilla = Planilla(
        id: '',
        mes: mesFormato,
        anio: _selectedDate.year,
        mesNumero: _selectedDate.month,
        fechaCreacion: DateTime.now(),
        estado: PlanillaEstado.pendienteRRHH,
        detalles: _detalles,
        firmas: {},
        montoTotal: montoTotal,
      );

      final planillaId = await _planillaService.crearPlanilla(planilla);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Planilla guardada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Navegar a la pantalla de firma
      Navigator.of(context).pushReplacementNamed(
        '/revisar-planilla',
        arguments: planillaId,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar planilla: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resumen = _isCalculated
        ? _calculoService.obtenerResumenPlanilla(_detalles)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Planilla'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Selector de mes
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seleccionar Periodo',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                                initialDatePickerMode: DatePickerMode.year,
                              );
                              if (date != null) {
                                setState(() {
                                  _selectedDate = date;
                                  _isCalculated = false;
                                  _detalles = [];
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('MMMM yyyy', 'es')
                                        .format(_selectedDate),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Icon(Icons.calendar_today),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Información de empleados
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Empleados Activos',
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_empleados.length} empleados',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.people,
                            size: 48,
                            color: Colors.blue.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botón calcular
                  if (!_isCalculated)
                    ElevatedButton.icon(
                      onPressed: _empleados.isEmpty ? null : _calcularPlanilla,
                      icon: const Icon(Icons.calculate),
                      label: const Text('CALCULAR PLANILLA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),

                  // Resumen de cálculos
                  if (_isCalculated && resumen != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resumen de Planilla',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.blue.shade900,
                                  ),
                            ),
                            const Divider(),
                            _buildResumenItem(
                              'Total Empleados:',
                              '${resumen['totalEmpleados']}',
                            ),
                            _buildResumenItem(
                              'Total Horas:',
                              '${resumen['totalHoras']} hrs',
                            ),
                            _buildResumenItem(
                              'Total Salarios:',
                              NumberFormat.currency(
                                symbol: 'S/. ',
                                decimalDigits: 2,
                              ).format(resumen['totalSalarios']),
                            ),
                            _buildResumenItem(
                              'Total Deducciones:',
                              NumberFormat.currency(
                                symbol: 'S/. ',
                                decimalDigits: 2,
                              ).format(resumen['totalDeducciones']),
                              color: Colors.red,
                            ),
                            _buildResumenItem(
                              'Total Bonificaciones:',
                              NumberFormat.currency(
                                symbol: 'S/. ',
                                decimalDigits: 2,
                              ).format(resumen['totalBonificaciones']),
                              color: Colors.green,
                            ),
                            const Divider(),
                            _buildResumenItem(
                              'NETO A PAGAR:',
                              NumberFormat.currency(
                                symbol: 'S/. ',
                                decimalDigits: 2,
                              ).format(resumen['totalNeto']),
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Detalles por empleado
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
                                      fontSize: 16,
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
                            itemCount: _detalles.length,
                            itemBuilder: (context, index) {
                              return _buildDetalleEmpleado(_detalles[index]);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Botón guardar y continuar
                    ElevatedButton.icon(
                      onPressed: _guardarPlanilla,
                      icon: const Icon(Icons.save),
                      label: const Text('GUARDAR Y CONTINUAR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildResumenItem(String titulo, String valor,
      {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: color ?? (isTotal ? Colors.blue.shade900 : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleEmpleado(DetallePlanilla detalle) {
    return ExpansionTile(
      title: Text(detalle.nombreEmpleado),
      subtitle: Text(
        'Neto: ${NumberFormat.currency(symbol: 'S/. ', decimalDigits: 2).format(detalle.netoAPagar)}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildDetalleRow('Salario Base:', detalle.salarioBase),
              _buildDetalleRow('Horas Trabajadas:', detalle.horasTrabajadas),
              _buildDetalleRow('Monto por Horas:', detalle.montoHoras),
              const Divider(),
              ...detalle.deducciones.entries.map((e) =>
                  _buildDetalleRow(e.key, e.value, color: Colors.red)),
              _buildDetalleRow('Total Deducciones:', detalle.totalDeducciones,
                  color: Colors.red, isBold: true),
              const Divider(),
              ...detalle.bonificaciones.entries.map((e) =>
                  _buildDetalleRow(e.key, e.value, color: Colors.green)),
              _buildDetalleRow(
                  'Total Bonificaciones:', detalle.totalBonificaciones,
                  color: Colors.green, isBold: true),
              const Divider(),
              _buildDetalleRow('NETO A PAGAR:', detalle.netoAPagar,
                  color: Colors.blue, isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetalleRow(String titulo, dynamic valor,
      {Color? color, bool isBold = false}) {
    final valorTexto = valor is double
        ? NumberFormat.currency(symbol: 'S/. ', decimalDigits: 2).format(valor)
        : valor.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            valorTexto,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
