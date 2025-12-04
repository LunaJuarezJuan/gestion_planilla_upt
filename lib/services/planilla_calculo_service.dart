import 'dart:math';
import '../models/empleado.dart';
import '../models/detalle_planilla.dart';

class PlanillaCalculoService {
  // Generar horas trabajadas aleatorias para un mes (solo L-V, 8 horas)
  int generarHorasTrabajadas(int anio, int mes) {
    final diasLaborables = _calcularDiasLaborables(anio, mes);
    // Podría haber variaciones por permisos, ausencias, etc.
    final random = Random();
    final diasTrabajados = diasLaborables - random.nextInt(3); // 0-2 días de ausencia
    return diasTrabajados * 8; // 8 horas por día
  }

  // Calcular días laborables (L-V) en un mes
  int _calcularDiasLaborables(int anio, int mes) {
    int diasLaborables = 0;
    final diasEnMes = DateTime(anio, mes + 1, 0).day;

    for (int dia = 1; dia <= diasEnMes; dia++) {
      final fecha = DateTime(anio, mes, dia);
      // 1 = Lunes, 5 = Viernes
      if (fecha.weekday >= 1 && fecha.weekday <= 5) {
        diasLaborables++;
      }
    }

    return diasLaborables;
  }

  // Calcular detalle de planilla para un empleado
  DetallePlanilla calcularDetallePlanilla({
    required Empleado empleado,
    required int anio,
    required int mes,
    Map<String, double>? deduccionesAdicionales,
    Map<String, double>? bonificacionesAdicionales,
  }) {
    final horasTrabajadas = generarHorasTrabajadas(anio, mes);
    
    // Calcular salario por hora
    final salarioPorHora = empleado.salarioBase / 160; // 160 horas mensuales estándar (20 días x 8 horas)
    final montoHoras = salarioPorHora * horasTrabajadas;

    // Deducciones estándar
    Map<String, double> deducciones = {
      'AFP (13%)': montoHoras * 0.13,
      'Salud (7%)': montoHoras * 0.07,
      'Impuesto Renta': _calcularImpuestoRenta(montoHoras),
    };

    // Agregar deducciones adicionales si existen
    if (deduccionesAdicionales != null) {
      deducciones.addAll(deduccionesAdicionales);
    }

    // Bonificaciones estándar
    Map<String, double> bonificaciones = {
      'Movilidad': 50.0,
      'Alimentación': 100.0,
    };

    // Agregar bonificaciones adicionales si existen
    if (bonificacionesAdicionales != null) {
      bonificaciones.addAll(bonificacionesAdicionales);
    }

    final totalDeducciones = deducciones.values.fold(0.0, (sum, valor) => sum + valor);
    final totalBonificaciones = bonificaciones.values.fold(0.0, (sum, valor) => sum + valor);
    final netoAPagar = montoHoras + totalBonificaciones - totalDeducciones;

    return DetallePlanilla(
      id: '',
      empleadoId: empleado.id,
      nombreEmpleado: empleado.nombreCompleto,
      salarioBase: empleado.salarioBase,
      horasTrabajadas: horasTrabajadas,
      montoHoras: montoHoras,
      deducciones: deducciones,
      bonificaciones: bonificaciones,
      totalDeducciones: totalDeducciones,
      totalBonificaciones: totalBonificaciones,
      netoAPagar: netoAPagar,
    );
  }

  // Calcular impuesto a la renta (simplificado)
  double _calcularImpuestoRenta(double ingreso) {
    // Tramos de impuesto simplificados (ejemplo)
    if (ingreso <= 2000) {
      return 0;
    } else if (ingreso <= 4000) {
      return (ingreso - 2000) * 0.08;
    } else if (ingreso <= 6000) {
      return 160 + (ingreso - 4000) * 0.14;
    } else {
      return 440 + (ingreso - 6000) * 0.20;
    }
  }

  // Calcular planilla completa para todos los empleados
  Future<List<DetallePlanilla>> calcularPlanillaCompleta({
    required List<Empleado> empleados,
    required int anio,
    required int mes,
  }) async {
    return empleados.map((empleado) {
      return calcularDetallePlanilla(
        empleado: empleado,
        anio: anio,
        mes: mes,
      );
    }).toList();
  }

  // Obtener resumen de la planilla
  Map<String, dynamic> obtenerResumenPlanilla(List<DetallePlanilla> detalles) {
    final totalEmpleados = detalles.length;
    final totalHoras = detalles.fold(0, (sum, d) => sum + d.horasTrabajadas);
    final totalSalarios = detalles.fold(0.0, (sum, d) => sum + d.montoHoras);
    final totalDeducciones = detalles.fold(0.0, (sum, d) => sum + d.totalDeducciones);
    final totalBonificaciones = detalles.fold(0.0, (sum, d) => sum + d.totalBonificaciones);
    final totalNeto = detalles.fold(0.0, (sum, d) => sum + d.netoAPagar);

    return {
      'totalEmpleados': totalEmpleados,
      'totalHoras': totalHoras,
      'totalSalarios': totalSalarios,
      'totalDeducciones': totalDeducciones,
      'totalBonificaciones': totalBonificaciones,
      'totalNeto': totalNeto,
    };
  }
}
