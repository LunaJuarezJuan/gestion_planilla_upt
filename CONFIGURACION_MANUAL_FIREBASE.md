# Configuración Manual de Firebase (Sin FlutterFire CLI)

## Paso 1: Archivos de Configuración Android

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto `bdevm3u`
3. Click en "Agregar app" → Android
4. Package name: `com.upt.gestion_planilla`
5. Descargar `google-services.json`
6. Colocar en: `android/app/google-services.json`

## Paso 2: Configurar build.gradle

### android/build.gradle
Agregar en `dependencies`:
```gradle
classpath 'com.google.gms:google-services:4.4.0'
```

### android/app/build.gradle
Agregar al final del archivo:
```gradle
apply plugin: 'com.google.gms.google-services'
```

Y cambiar:
```gradle
android {
    ...
    defaultConfig {
        applicationId "com.upt.gestion_planilla"
        minSdk 21  // Importante para Firebase
        targetSdk flutter.targetSdk
        ...
    }
}
```

## Paso 3: Crear firebase_options.dart

Crear archivo: `lib/firebase_options.dart`

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'TU_API_KEY_WEB',
    appId: 'TU_APP_ID_WEB',
    messagingSenderId: 'TU_SENDER_ID',
    projectId: 'bdevm3u',
    authDomain: 'bdevm3u.firebaseapp.com',
    storageBucket: 'bdevm3u.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TU_API_KEY_ANDROID',
    appId: 'TU_APP_ID_ANDROID',
    messagingSenderId: 'TU_SENDER_ID',
    projectId: 'bdevm3u',
    storageBucket: 'bdevm3u.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TU_API_KEY_IOS',
    appId: 'TU_APP_ID_IOS',
    messagingSenderId: 'TU_SENDER_ID',
    projectId: 'bdevm3u',
    storageBucket: 'bdevm3u.appspot.com',
    iosBundleId: 'com.upt.gestionPlanilla',
  );
}
```

**NOTA:** Reemplaza los valores `TU_API_KEY_*` con los valores reales de tu proyecto Firebase.

Para obtener estos valores:
1. Firebase Console → Project Settings → General
2. Scroll down → Your apps
3. Verás los valores de configuración para cada plataforma

## Paso 4: Actualizar main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

## Paso 5: Ejecutar

```bash
flutter clean
flutter pub get
flutter run
```
