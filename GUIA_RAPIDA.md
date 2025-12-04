# 🚀 GUÍA RÁPIDA DE INICIO

## Pasos para Ejecutar el Proyecto

### 1. Verificar Requisitos Previos
```bash
# Verificar Flutter
flutter doctor

# Debe mostrar:
# ✓ Flutter (Channel stable)
# ✓ Android toolchain
# ✓ Chrome/Edge/Safari para Web
```

### 2. Instalar Dependencias
```bash
cd gestion_planilla_upt
flutter pub get
```

### 3. Configurar Firebase (IMPORTANTE)

#### Opción A: Configuración Rápida (Desarrollo)
1. Crear proyecto en [Firebase Console](https://console.firebase.google.com/)
2. Nombre: "Gestion Planilla UPT"
3. Agregar app Android:
   - Package: `com.upt.gestion_planilla`
   - Descargar `google-services.json` → `android/app/`

4. Habilitar servicios:
   - **Authentication** → Email/Password ✅
   - **Firestore Database** → Modo test ✅
   - **Storage** → Modo test ✅
   - **Cloud Messaging** → Activar ✅

5. Reglas de Firestore (modo desarrollo):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

6. Reglas de Storage (modo desarrollo):
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Opción B: Configuración Completa
Ver: `FIREBASE_SETUP.md`

### 4. Crear Datos Iniciales

#### 4.1 Usuario RRHH (Administrador)
En Firebase Console → Authentication:
```
Email: rrhh@upt.edu.pe
Password: Admin123!
```

Copiar el UID generado.

En Firestore → Colección `usuarios` → Nuevo documento (usar el UID copiado):
```json
{
  "email": "rrhh@upt.edu.pe",
  "nombre": "Admin",
  "apellido": "RRHH",
  "rol": "rrhh",
  "fechaCreacion": [Usar Timestamp actual],
  "activo": true
}
```

#### 4.2 Empleados de Prueba
En Firestore → Colección `empleados` → Agregar documentos:

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
  "email": "juan.perez@empresa.com"
}
```

```json
{
  "nombre": "María",
  "apellido": "González",
  "dni": "87654321",
  "cargo": "Diseñadora",
  "salarioBase": 2800,
  "numeroCuenta": "0987654321",
  "banco": "BBVA",
  "fechaIngreso": [Timestamp],
  "activo": true,
  "email": "maria.gonzalez@empresa.com"
}
```

Crear al menos **5 empleados** para probar el sistema.

### 5. Ejecutar la Aplicación

```bash
# Para Android
flutter run -d android

# Para Web
flutter run -d chrome

# Para Windows
flutter run -d windows
```

### 6. Primer Login

1. La app abrirá en la pantalla de Login
2. Ingresar:
   - **Email:** rrhh@upt.edu.pe
   - **Password:** Admin123!
3. Click en "INICIAR SESIÓN"

### 7. Crear Primera Planilla

1. En el Dashboard de RRHH, click en **"Nueva Planilla"**
2. Seleccionar mes (ejemplo: Diciembre 2024)
3. Verificar empleados cargados
4. Click en **"CALCULAR PLANILLA"**
5. Revisar los cálculos:
   - Horas generadas automáticamente (L-V, 8 hrs)
   - Deducciones calculadas
   - Bonificaciones aplicadas
   - Neto a pagar
6. Click en **"GUARDAR Y CONTINUAR"**

### 8. Revisar y Firmar (RRHH)

1. Se abrirá la pantalla de revisión
2. Revisar detalles de la planilla
3. **Capturar firma digital:**
   - Dibujar firma en el canvas
   - Click en "Confirmar Firma"
4. Opcionalmente agregar comentarios
5. Click en **"APROBAR Y FIRMAR"**

¡Listo! La planilla está creada y firmada por RRHH.

### 9. Crear Otros Usuarios (Opcional)

Para probar el flujo completo, crear usuarios para cada rol:

**Gerente Financiero:**
```
Auth: gfinanciero@upt.edu.pe / Gerente123!

Firestore usuarios/[nuevo UID]:
{
  "email": "gfinanciero@upt.edu.pe",
  "nombre": "Carlos",
  "apellido": "Rodríguez",
  "rol": "gerente_financiero",
  "fechaCreacion": [Timestamp],
  "activo": true
}
```

**Gerente General:**
```
Auth: ggeneral@upt.edu.pe / Gerente123!

Firestore usuarios/[nuevo UID]:
{
  "email": "ggeneral@upt.edu.pe",
  "nombre": "Ana",
  "apellido": "Martínez",
  "rol": "gerente_general",
  "fechaCreacion": [Timestamp],
  "activo": true
}
```

Y así con Tesorería y Contabilidad.

## 🎯 Flujo de Prueba Completo

1. **Login como RRHH** → Crear y firmar planilla
2. **Logout** → Login como **Gerente Financiero** → Revisar y firmar
3. **Logout** → Login como **Gerente General** → Aprobar y firmar
4. **Logout** → Login como **Tesorería** → Confirmar pago
5. **Logout** → Login como **Contabilidad** → Registro final
6. Ver PDF generado con todas las firmas

## ⚡ Comandos Útiles

```bash
# Limpiar build
flutter clean

# Reinstalar dependencias
flutter pub get

# Ver logs en tiempo real
flutter run --verbose

# Build para producción Android
flutter build apk --release

# Verificar análisis de código
flutter analyze

# Formatear código
dart format lib/
```

## 🐛 Solución de Problemas Comunes

### Error: "Firebase not initialized"
**Solución:** Verificar que `google-services.json` esté en `android/app/`

### Error: "User not found"
**Solución:** Crear usuario en Firebase Authentication primero

### Error: "Permission denied"
**Solución:** Revisar reglas de Firestore y Storage

### No se ven los empleados
**Solución:** Crear empleados en Firestore colección `empleados`

### La firma no se captura
**Solución:** Asegurarse de hacer clic en "Confirmar Firma" después de dibujar

## 📱 Navegación de la App

```
LoginScreen
    ↓
HomeScreen (Dashboard según rol)
    ├── RRHH Dashboard
    │   ├── Nueva Planilla → CrearPlanillaScreen
    │   ├── Ver Planillas
    │   ├── Empleados
    │   └── Pendientes Firma → RevisarPlanillaScreen
    │
    ├── Gerente Dashboard
    │   ├── Planillas Pendientes → RevisarPlanillaScreen
    │   ├── Historial
    │   └── Reportes
    │
    └── Otros Roles...
```

## 📊 Datos de Ejemplo para Pruebas

### Empleados Sugeridos (5-10):
1. Juan Pérez - Desarrollador - S/. 3000
2. María González - Diseñadora - S/. 2800
3. Carlos Ruiz - Analista - S/. 3200
4. Ana Torres - Project Manager - S/. 3500
5. Luis Vargas - QA Tester - S/. 2600
6. Sofia Ramírez - DevOps - S/. 3300
7. Pedro Castro - Backend Dev - S/. 3100
8. Laura Mendoza - Frontend Dev - S/. 2900
9. Diego Flores - Mobile Dev - S/. 3000
10. Carmen Silva - UI/UX - S/. 2700

### Cálculos Esperados (ejemplo para Diciembre 2024):
- Días laborables (L-V): ~22 días
- Horas esperadas: ~176 horas (22 días × 8 hrs)
- Con variación: 160-176 horas
- Deducciones: ~20% del salario
- Bonificaciones: S/. 150 (Movilidad + Alimentación)

## ✅ Checklist de Verificación

Antes de presentar el proyecto, verificar:

- [ ] Firebase configurado correctamente
- [ ] Al menos 5 empleados creados
- [ ] Usuario RRHH funcional
- [ ] Login exitoso
- [ ] Planilla se crea correctamente
- [ ] Horas se generan automáticamente (L-V)
- [ ] Cálculos son correctos
- [ ] Firma digital funciona
- [ ] Estados de planilla cambian correctamente
- [ ] No hay errores en consola

## 📞 Soporte

Si encuentras problemas:
1. Revisar logs: `flutter run --verbose`
2. Verificar Firebase Console
3. Consultar `FIREBASE_SETUP.md`
4. Ver `PROYECTO_RESUMEN.md`

---

**¡Todo listo para probar el sistema completo!** 🎉
