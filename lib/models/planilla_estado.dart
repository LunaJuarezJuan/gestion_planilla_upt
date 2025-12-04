enum PlanillaEstado {
  enCalculo, // FASE 1: RRHH calculando
  pendienteRRHH, // FASE 2: Esperando firma RRHH
  pendienteGerenteFinanciero, // FASE 3: Esperando Gerente Financiero
  pendienteGerenteGeneral, // FASE 3: Esperando Gerente General
  pendienteTesoreria, // FASE 4: Esperando pago
  pendienteContabilidad, // FASE 4: Esperando registro contable
  completada, // FASE 5: Completada
  rechazada, // Rechazada en cualquier fase
}

extension PlanillaEstadoExtension on PlanillaEstado {
  String get displayName {
    switch (this) {
      case PlanillaEstado.enCalculo:
        return 'En Cálculo';
      case PlanillaEstado.pendienteRRHH:
        return 'Pendiente Firma RRHH';
      case PlanillaEstado.pendienteGerenteFinanciero:
        return 'Pendiente Gerente Financiero';
      case PlanillaEstado.pendienteGerenteGeneral:
        return 'Pendiente Gerente General';
      case PlanillaEstado.pendienteTesoreria:
        return 'Pendiente Tesorería';
      case PlanillaEstado.pendienteContabilidad:
        return 'Pendiente Contabilidad';
      case PlanillaEstado.completada:
        return 'Completada';
      case PlanillaEstado.rechazada:
        return 'Rechazada';
    }
  }

  String get key {
    switch (this) {
      case PlanillaEstado.enCalculo:
        return 'en_calculo';
      case PlanillaEstado.pendienteRRHH:
        return 'pendiente_rrhh';
      case PlanillaEstado.pendienteGerenteFinanciero:
        return 'pendiente_gerente_financiero';
      case PlanillaEstado.pendienteGerenteGeneral:
        return 'pendiente_gerente_general';
      case PlanillaEstado.pendienteTesoreria:
        return 'pendiente_tesoreria';
      case PlanillaEstado.pendienteContabilidad:
        return 'pendiente_contabilidad';
      case PlanillaEstado.completada:
        return 'completada';
      case PlanillaEstado.rechazada:
        return 'rechazada';
    }
  }

  static PlanillaEstado fromString(String estado) {
    switch (estado.toLowerCase()) {
      case 'en_calculo':
        return PlanillaEstado.enCalculo;
      case 'pendiente_rrhh':
        return PlanillaEstado.pendienteRRHH;
      case 'pendiente_gerente_financiero':
        return PlanillaEstado.pendienteGerenteFinanciero;
      case 'pendiente_gerente_general':
        return PlanillaEstado.pendienteGerenteGeneral;
      case 'pendiente_tesoreria':
        return PlanillaEstado.pendienteTesoreria;
      case 'pendiente_contabilidad':
        return PlanillaEstado.pendienteContabilidad;
      case 'completada':
        return PlanillaEstado.completada;
      case 'rechazada':
        return PlanillaEstado.rechazada;
      default:
        return PlanillaEstado.enCalculo;
    }
  }
}
