# Hypnos Dream Journal - Setup Guide

## Descripción
Guía de configuración inicial del proyecto Flutter para Hypnos Dream Journal con integración Firebase.

**Fase:** 2  
**Sprint:** 2  
**Estado:** Base structure ready for development

---

## Requisitos previos

### Software requerido
- Flutter 3.13.5+ (SDK: ^3.11.5)
- Dart 3.11.5+
- Android Studio o Xcode (según plataforma)
- Git
- Firebase CLI (opcional, pero recomendado)

### Verificar instalación
```bash
flutter --version
dart --version
flutter doctor
```

---

## Instalación inicial

### 1. Clonar/descargar el proyecto
```bash
cd path/to/hypnos_dreamjournal
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Generar archivos de configuración (si es necesario)
```bash
flutter pub run build_runner build
```

### 4. Ejecutar la app
```bash
# iOS (macOS)
flutter run -d "iPhone 15"

# Android
flutter run -d "emulator-5554"

# Web
flutter run -d chrome

# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

---

## Estructura del Proyecto

```
lib/
├── app/                          # Aplicación shell
│   ├── bootstrap.dart            # Inicialización de la app
│   ├── theme/                    # Temas y estilos (a crear)
│   └── router/                   # Navegación/rutas (a crear)
│
├── features/                     # Características modulares
│   ├── auth/                     # Autenticación
│   │   ├── models/              # DTOs de auth
│   │   ├── pages/               # Vistas (login, signup)
│   │   ├── providers/           # State management (Provider)
│   │   └── widgets/             # Widgets reutilizables
│   │
│   ├── dreams/                   # Gestión de sueños
│   │   ├── models/              # DTOs específicos
│   │   ├── pages/               # Home, capture, detail
│   │   ├── providers/           # State management
│   │   └── widgets/             # Dream components
│   │
│   └── profile/                  # Perfil de usuario
│       ├── pages/
│       ├── providers/
│       └── widgets/
│
├── data/                         # Capa de datos
│   ├── models/                   # Modelos de dominio
│   │   ├── user_model.dart
│   │   ├── dream_model.dart
│   │   └── insight_model.dart
│   │
│   ├── services/                 # Servicios (Firebase, etc)
│   │   └── firebase_service.dart
│   │
│   └── repositories/             # Repositories (patrón)
│       ├── auth_repository.dart
│       └── dream_repository.dart
│
├── shared/                       # Código compartido
│   ├── errors/
│   │   ├── exceptions.dart      # Custom exceptions
│   │   └── result.dart          # Tipo Result<T> para errores
│   │
│   ├── extensions/               # Extensiones de Dart (a crear)
│   │   └── (date_time_ext.dart, string_ext.dart)
│   │
│   ├── utils/                    # Utilidades (a crear)
│   │   └── (validators.dart, formatters.dart)
│   │
│   └── widgets/                  # Widgets compartidos (a crear)
│       └── (loading_indicator.dart, error_widget.dart)
│
├── core/                         # Configuración central
│   ├── config/
│   │   └── app_config.dart
│   │
│   └── constants/
│       └── app_constants.dart
│
├── firebase_options.dart         # Configuración Firebase (generado)
└── main.dart                     # Entry point
```

### Estructura por capas

**app/** - Shell de la aplicación
- Inicialización, bootstrap, tema global, navegación

**features/** - Módulos independientes (Repository Pattern)
- `models/` - DTOs y representación de datos
- `pages/` - Pantallas (UI)
- `providers/` - State management (Provider)
- `widgets/` - Componentes reutilizables

**data/** - Capa de datos (Repository Pattern)
- `models/` - Modelos de dominio (entidades de negocio)
- `services/` - Integraciones externas (Firebase, APIs)
- `repositories/` - Abstracciones de acceso a datos

**shared/** - Código reutilizable
- `errors/` - Manejo de excepciones
- `extensions/` - Extensiones de Dart
- `utils/` - Funciones de utilidad
- `widgets/` - Widgets compartidos

**core/** - Configuración central
- `config/` - Configuración de ambiente
- `constants/` - Constantes globales

---

## Dependencias principales

### Firebase
```yaml
firebase_core: ^2.25.4        # Core de Firebase
firebase_auth: ^4.17.4        # Autenticación
cloud_firestore: ^4.15.4      # Base de datos
firebase_storage: ^11.6.5     # Almacenamiento de audio
```

### Estado
```yaml
provider: ^6.1.1              # State management
```

### Navegación
```yaml
go_router: ^13.2.0            # Routing declarativo
```

### Audio
```yaml
record: ^6.0.0                # Grabación de audio
just_audio: ^0.9.38           # Reproducción
```

### IA y procesamiento
```yaml
speech_to_text: ^6.6.0        # Transcripción de voz
google_generative_ai: ^0.3.1  # Google Gemini API
```

### UI y utilidades
```yaml
fl_chart: ^0.67.0             # Gráficos
cached_network_image: ^3.3.1  # Imágenes en cache
intl: ^0.19.0                 # Internacionalización
uuid: ^4.0.0                  # UUID generation
equatable: ^2.0.5             # Igualdad de objetos
logger: ^2.1.0                # Logging
```

---

## Modelos principales

### User (usuario)
```dart
User(
  id: String,                    // Firebase UID
  email: String,
  displayName: String?,
  aiEnabled: bool,               // IA activada/desactivada
  biometricEnabled: bool,
  timezone: String,
  privacySettings: PrivacySettings,
  createdAt: DateTime,
  updatedAt: DateTime,
)
```

### Dream (entrada de sueño)
```dart
Dream(
  id: String,
  userId: String,
  title: String,
  description: String?,
  audioUrl: String?,             // Audio guardado en Storage
  transcription: String?,        // Resultado de STT
  recordedAt: DateTime,
  moodTags: List<String>,        // Etiquetas de ánimo
  characters: List<String>,      // Personajes mencionados
  locations: List<String>,       // Lugares
  themes: List<String>,          // Temas/símbolos
  emotionalAnalysis: EmotionalAnalysis?,  // Análisis IA
  qualityRating: int?,           // 1-10 del usuario
  isFavorite: bool,
  isProcessing: bool,            // En proceso de análisis
)
```

### Insight (análisis/patrón)
```dart
Insight(
  id: String,
  userId: String,
  type: InsightType,             // recurring_emotion, pattern_detection, etc.
  title: String,
  description: String,
  metrics: Map<String, dynamic>, // Datos de análisis
  confidenceScore: double,       // 0.0 - 1.0
  relatedDreamIds: List<String>,
  recommendations: List<String>, // Recomendaciones accionables
)
```

---

## Servicios principales

### FirebaseService (inicialización)
```dart
// Inicializar en main() vía bootstrap
await FirebaseService.initialize();

// Acceder a instancias
final auth = FirebaseService.auth;
final firestore = FirebaseService.firestore;
final storage = FirebaseService.storage;
```

### AuthRepository (autenticación)
```dart
// Sign up
await authRepo.signUp(
  email: 'user@example.com',
  password: 'password123',
  displayName: 'User Name',
);

// Sign in
await authRepo.signIn(
  email: 'user@example.com',
  password: 'password123',
);

// Listen to auth state
authRepo.authStateChanges().listen((user) {
  // Update UI based on auth state
});
```

### DreamRepository (sueños)
```dart
// Crear sueño
await dreamRepo.createDream(
  userId: 'user_id',
  title: 'Title',
  description: 'Description',
  moodTags: ['happy', 'calm'],
);

// Obtener sueños del usuario
final dreams = await dreamRepo.getDreamsByUser(userId: 'user_id');

// Escuchar cambios en tiempo real
dreamRepo.streamUserDreams(userId: 'user_id').listen((dreams) {
  // Update UI
});
```

---

## Manejo de errores

La app usa el patrón `Result<T>` (Either) para manejo funcional de errores:

```dart
// Resultado exitoso
const Success(value);

// Resultado fallido
Failure(exception);

// Uso
final result = await authRepo.signIn(...);
result.whenSuccess((value) => print('Success'));
result.whenFailure((error) => print('Error: $error'));

// O con pattern matching
final user = switch(result) {
  Success(value: final u) => u,
  Failure(exception: final e) => throw e,
};
```

---

## Próximas etapas

### Inmediatas (Sprint 2 continuación)
1. [ ] Crear UI screens base (Login, Home, Capture, Detail)
2. [ ] Implementar state management con Provider
3. [ ] Conectar auth flow completo
4. [ ] Configurar navegación con GoRouter

### Corto plazo (Sprint 3)
1. [ ] Implementar CRUD de sueños
2. [ ] Audio recording + upload a Storage
3. [ ] Integración de speech-to-text
4. [ ] Testing unitario de repositories

### Mediano plazo (Fase 3)
1. [ ] Integración de Google Gemini para análisis
2. [ ] Cloud Functions para procesamiento async
3. [ ] Dashboard de análisis y estadísticas
4. [ ] Biometric authentication

---

## Comandos útiles

```bash
# Ejecutar con logs
flutter run -v

# Ejecutar en modo profile (performance)
flutter run --profile

# Ejecutar en modo release
flutter run --release

# Limpiar build
flutter clean

# Rebuild pubspec
flutter pub get

# Generate code (si se agrega build_runner)
flutter pub run build_runner build

# Análisis de código
flutter analyze

# Formateo de código
dart format lib/

# Pruebas
flutter test

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

---

## Firebase Setup checklist

- [ ] Firebase project creado en Firebase Console
- [ ] Android: `google-services.json` descargado y colocado en `android/app/`
- [ ] iOS: `GoogleService-Info.plist` descargado y agregado a Xcode
- [ ] Web: `firebaseConfig` configurado en `web/index.html` (si aplica)
- [ ] Firestore collections creadas: `users`, `dreams`, `insights`
- [ ] Firebase Storage bucket configurado para audio
- [ ] Firebase Security Rules configuradas (próxima sprint)
- [ ] Google Gemini API key agregada a `.env` (desarrollo)

---

## Troubleshooting

### "FirebaseService not initialized"
- Asegurar que `appBootstrap()` se llama antes de `runApp()`
- Verificar que Firebase options están correctamente configuradas

### "Plugin not found" errors
```bash
flutter clean
flutter pub get
flutter pub get (run again)
```

### "Firestore not found" en runtime
- Verificar que las collections existen en Firebase Console
- Verificar reglas de seguridad no están bloqueando lecturas

### Build errors Android/iOS
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
# iOS
cd ios && pod repo update && pod install && cd ..
```

---

## Documentación adicional

- [Flutter docs](https://flutter.dev/docs)
- [Firebase Flutter docs](https://firebase.flutter.dev/)
- [Provider docs](https://pub.dev/packages/provider)
- [GoRouter docs](https://pub.dev/packages/go_router)
- Decisiones de diseño: `.github/agents/phase-1-analysis-design-deliverable.md`
- Contexto de app: `.github/agents/shared-app-context.md`

---

**Última actualización:** 2026-04-30  
**Versión:** 1.0.0
