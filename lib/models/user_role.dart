enum UserRole {
  rrhh,
  gerenteFinanciero,
  gerenteGeneral,
  tesoreria,
  contabilidad,
  empleado,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.rrhh:
        return 'Recursos Humanos';
      case UserRole.gerenteFinanciero:
        return 'Gerente Financiero';
      case UserRole.gerenteGeneral:
        return 'Gerente General';
      case UserRole.tesoreria:
        return 'Tesorería';
      case UserRole.contabilidad:
        return 'Contabilidad';
      case UserRole.empleado:
        return 'Empleado';
    }
  }

  String get key {
    switch (this) {
      case UserRole.rrhh:
        return 'rrhh';
      case UserRole.gerenteFinanciero:
        return 'gerente_financiero';
      case UserRole.gerenteGeneral:
        return 'gerente_general';
      case UserRole.tesoreria:
        return 'tesoreria';
      case UserRole.contabilidad:
        return 'contabilidad';
      case UserRole.empleado:
        return 'empleado';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'rrhh':
        return UserRole.rrhh;
      case 'gerente_financiero':
        return UserRole.gerenteFinanciero;
      case 'gerente_general':
        return UserRole.gerenteGeneral;
      case 'tesoreria':
        return UserRole.tesoreria;
      case 'contabilidad':
        return UserRole.contabilidad;
      case 'empleado':
        return UserRole.empleado;
      default:
        return UserRole.empleado;
    }
  }
}
