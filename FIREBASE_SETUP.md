# Configuración de Firebase

Este archivo contiene las instrucciones para configurar Firebase en el proyecto.

## Paso 1: Crear Proyecto en Firebase

1. Ir a [Firebase Console](https://console.firebase.google.com/)
2. Crear nuevo proyecto llamado "Gestion Planilla UPT"
3. Habilitar Google Analytics (opcional)

## Paso 2: Registrar Apps

### Android
```bash
Nombre del paquete: com.upt.gestion_planilla
```

### iOS
```bash
Bundle ID: com.upt.gestionPlanilla
```

## Paso 3: Descargar Archivos de Configuración

### Android
- Descargar `google-services.json`
- Colocar en: `android/app/google-services.json`

### iOS
- Descargar `GoogleService-Info.plist`
- Colocar en: `ios/Runner/GoogleService-Info.plist`

## Paso 4: Habilitar Servicios

### 1. Authentication
- Ir a Authentication > Sign-in method
- Habilitar "Email/Password"

### 2. Cloud Firestore
- Ir a Firestore Database
- Crear base de datos en modo producción
- Seleccionar ubicación: us-central

### 3. Cloud Storage
- Ir a Storage
- Comenzar en modo producción

### 4. Cloud Messaging
- Ir a Cloud Messaging
- Habilitar el servicio

## Paso 5: Configurar Índices de Firestore

En Firestore > Índices, crear:

```
Collection: planillas
Fields: anio (Ascending), mesNumero (Descending)

Collection: planillas
Fields: estado (Ascending), fechaCreacion (Descending)
```

## Paso 6: Datos Iniciales

### Crear Usuario Administrador RRHH

1. Ir a Authentication > Users
2. Add user:
   - Email: rrhh@upt.edu.pe
   - Password: Admin123!

3. Copiar el UID generado

4. Ir a Firestore Database
5. Crear colección `usuarios`
6. Crear documento con el UID copiado:

```json
{
  "email": "rrhh@upt.edu.pe",
  "nombre": "Administrador",
  "apellido": "RRHH",
  "rol": "rrhh",
  "fechaCreacion": [Timestamp actual],
  "activo": true
}
```

### Crear Empleados de Ejemplo

Colección: `empleados`

```json
{
  "nombre": "Juan",
  "apellido": "Pérez",
  "dni": "12345678",
  "cargo": "Desarrollador",
  "salarioBase": 3000,
  "numeroCuenta": "1234567890",
  "banco": "BCP",
  "fechaIngreso": [Timestamp],
  "activo": true,
  "email": "juan.perez@upt.edu.pe"
}
```

Crear al menos 5-10 empleados para pruebas.

### Crear Usuarios por Rol

1. **Gerente Financiero**
```json
Auth: gerente.financiero@upt.edu.pe / Gerente123!

Firestore usuarios/[UID]:
{
  "email": "gerente.financiero@upt.edu.pe",
  "nombre": "Carlos",
  "apellido": "Rodríguez",
  "rol": "gerente_financiero",
  "fechaCreacion": [Timestamp],
  "activo": true
}
```

2. **Gerente General**
```json
Auth: gerente.general@upt.edu.pe / Gerente123!

Firestore usuarios/[UID]:
{
  "email": "gerente.general@upt.edu.pe",
  "nombre": "María",
  "apellido": "González",
  "rol": "gerente_general",
  "fechaCreacion": [Timestamp],
  "activo": true
}
```

3. **Tesorería**
```json
Auth: tesoreria@upt.edu.pe / Tesoro123!

Firestore usuarios/[UID]:
{
  "email": "tesoreria@upt.edu.pe",
  "nombre": "Ana",
  "apellido": "Martínez",
  "rol": "tesoreria",
  "fechaCreacion": [Timestamp],
  "activo": true
}
```

4. **Contabilidad**
```json
Auth: contabilidad@upt.edu.pe / Conta123!

Firestore usuarios/[UID]:
{
  "email": "contabilidad@upt.edu.pe",
  "nombre": "Luis",
  "apellido": "Torres",
  "rol": "contabilidad",
  "fechaCreacion": [Timestamp],
  "activo": true
}
```

## Paso 7: Configurar Notificaciones (Opcional)

### Android
1. Descargar server key de Firebase
2. Agregar a las configuraciones del proyecto

### iOS
1. Subir certificado APN
2. Configurar en Xcode

## Verificación

Después de configurar todo:

1. Ejecutar: `flutter pub get`
2. Ejecutar: `flutter run`
3. Intentar login con: rrhh@upt.edu.pe / Admin123!
4. Verificar que carga el dashboard de RRHH

## Troubleshooting

### Error: google-services.json not found
- Verificar que el archivo esté en `android/app/`

### Error: Firebase not initialized
- Verificar que `Firebase.initializeApp()` se ejecute en `main()`

### Error: Permission denied
- Verificar reglas de Firestore y Storage

## Recursos

- [Documentación Firebase](https://firebase.google.com/docs)
- [FlutterFire](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
