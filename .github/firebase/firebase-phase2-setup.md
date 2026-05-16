# Firebase Phase 2 Setup Guide

**Proyecto:** Hypnos Dream Journal  
**Fase:** 2 (Sprint 1 cierre / Sprint 2 inicio)  
**Fecha:** 2026-04-30  
**Estado:** Setup listo para despliegue

---

## 1. Configuración de Firebase existente

### Project Details
```
Project ID:        hypnos-deamjournal
Project Name:      hypnos-deamjournal (en GCP)
API Key (Android): AIzaSyB0_GKL2j4N3ztvu2gvGl9C80TZ4GWVjZo
API Key (iOS):     AIzaSyAz50whvs0gcYk1AtOrfSxrIw0WikhndB0
Sender ID:         825550148513
Storage Bucket:    hypnos-deamjournal.firebasestorage.app
```

### Aplicaciones registradas
- ✅ Android: `com.example.hypnosDreamjournal` (ID: `1:825550148513:android:d7831ae456ff4e4c21f1e0`)
- ✅ iOS: `com.example.hypnosDreamjournal` (ID: `1:825550148513:ios:19a09e4151e7e5d021f1e0`)

### Configuración Flutter
```dart
// firebase_options.dart - CONFIGURADO
DefaultFirebaseOptions.android
DefaultFirebaseOptions.ios
```

---

## 2. Firebase Authentication Setup

### 2.1 Enable Authentication Methods

#### Email/Password (Requerido - Fase 2)
1. **Ir a:** Firebase Console → Authentication → Sign-in method
2. **Activar:** Email/Password
   - ✅ Email enumeration protection: ON
   - ✅ Create account: ENABLED (usuarios pueden registrarse)

#### Google Sign-In (Opcional - Planned Fase 3)
1. **Activar:** Google Sign-In
   - Requiere OAuth Consent Screen configurado en GCP
   - iOS: Configurar OAuth redirect en Firebase Console
   - Android: SHA-1 fingerprint registrado (en google-services.json)

### 2.2 Password Policy
- Mínimo: 6 caracteres (default Firebase)
- Recomendación: Incrementar a 8+ en Fase 3 si se implementa 2FA

### 2.3 Email Verification (Recomendado)
```
Firebase Console → Authentication → Templates → Verification Email
- Remitente personalizado (opcional)
- Redirección después de verificación
```

### 2.4 User Management
- Cuota: 1M signups/mes (plan Spark - gratuito)
- Monitoreo: Dashboard mostrará métrica de activos


---

## 3. Firestore Database Setup

### 3.1 Crear Firestore Instance
1. **Ir a:** Firebase Console → Firestore Database → Create Database
2. **Configuración:**
   - Modo: **Production** (reglas estrictas son mandatorias)
   - Región: `us-central1` (latencia óptima para Norte América)
   - Tipo: **Cloud Firestore**

### 3.2 Aplicar Security Rules
1. **Archivo:** `.github/firebase/firestore.rules`
2. **Desplegar:**
   ```bash
   # Option A: Firebase CLI
   firebase deploy --only firestore:rules
   
   # Option B: Console
   # Firestore → Rules → Copy/paste contenido de firestore.rules
   ```

### 3.3 Estructura de colecciones

```
firestore-root/
├── users/
│   ├── {uid}/
│   │   ├── displayName: string
│   │   ├── email: string
│   │   ├── createdAt: timestamp
│   │   ├── aiEnabled: bool
│   │   ├── timezone: string
│   │   │
│   │   └── dreams/ (subcollection)
│   │       └── {dreamId}/
│   │           ├── title: string
│   │           ├── text: string
│   │           ├── dreamDate: timestamp
│   │           ├── createdAt: timestamp
│   │           ├── updatedAt: timestamp
│   │           ├── moodScore: number | null
│   │           ├── tags: array<string>
│   │           ├── hasAudio: bool
│   │           ├── audioPath: string | null
│   │           ├── transcription: string | null
│   │           └── aiSummary: string | null
│   │
│   │   └── insights/ (subcollection)
│   │       └── {insightId}/
│   │           ├── periodStart: timestamp
│   │           ├── periodEnd: timestamp
│   │           ├── dominantEmotions: array<string>
│   │           ├── recurringTags: array<string>
│   │           └── generatedAt: timestamp
```

---

## 4. Cloud Storage Setup

### 4.1 Crear Storage Bucket
1. **Ir a:** Firebase Console → Storage → Create Bucket
2. **Configuración:**
   - Bucket ID: `hypnos-deamjournal.firebasestorage.app` (default)
   - Región: `us-central1`
   - Clase de almacenamiento: `Standard`

### 4.2 Aplicar Storage Security Rules
1. **Archivo:** `.github/firebase/storage.rules`
2. **Desplegar:**
   ```bash
   # Option A: Firebase CLI
   firebase deploy --only storage
   
   # Option B: Console
   # Storage → Rules → Copy/paste contenido de storage.rules
   ```

### 4.3 Estructura de rutas
```
gs://hypnos-deamjournal.firebasestorage.app/
└── users/
    └── {uid}/
        └── dreams/
            └── {dreamId}/
                └── audio.m4a (máximo 100 MB)
```

---

## 5. Firebase Configuration in Flutter

### 5.1 Verificar `firebase_options.dart`
```dart
// ✅ Ya configurado con API keys
DefaultFirebaseOptions.android
DefaultFirebaseOptions.ios
```

### 5.2 Inicializar Firebase en main.dart
```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

### 5.3 Dependencias requeridas (en pubspec.yaml)
```yaml
dependencies:
  firebase_core: ^2.25.4
  firebase_auth: ^4.17.4
  cloud_firestore: ^4.15.4
  firebase_storage: ^11.6.5
```

---

## 6. Security & Access Control Summary

### Authentication Flow
```
User Registration/Login
     ↓
Firebase Auth (Email/Password)
     ↓
Custom User Document en Firestore (users/{uid})
     ↓
Access Control via Firestore Rules (ownership)
```

### Access Patterns
| Recurso | Operación | Permitido a | Regla |
|---------|-----------|------------|-------|
| `users/{uid}` | Read | Propietario | `isOwner(uid)` |
| `users/{uid}` | Create | Self | First signup |
| `users/{uid}` | Update | Propietario | Solo datos mutables |
| `users/{uid}/dreams/{dreamId}` | Read | Propietario | `isOwner(uid)` |
| `users/{uid}/dreams/{dreamId}` | Create | Propietario | New dream entry |
| `users/{uid}/dreams/{dreamId}` | Update | Propietario | Only dream owner |
| `users/{uid}/insights/{insightId}` | Read | Propietario | `isOwner(uid)` |
| `storage:audio.m4a` | Read | Propietario | Path validation |
| `storage:audio.m4a` | Write | Propietario | Type + Size validation |

### Key Security Principles Implemented
1. ✅ **Least Privilege:** Denegar por defecto, abrir solo por necesidad
2. ✅ **Ownership Validation:** Todos los datos vinculados a `uid`
3. ✅ **Data Validation:** Tipos y límites de tamaño en reglas
4. ✅ **No Anonymous Access:** Toda operación requiere autenticación
5. ✅ **Immutable Fields:** `createdAt` no puede ser modificado

---

## 7. Validación Pre-Desarrollo

### Checklist

- [ ] **Firebase Project**
  - [ ] Project ID verificado: `hypnos-deamjournal`
  - [ ] API keys configuradas en Firebase Console
  - [ ] Ambiente Production activado

- [ ] **Authentication**
  - [ ] Email/Password habilitado en Console
  - [ ] Email verification templates configurados (opcional)
  - [ ] Google OAuth (cuando se implemente en Fase 3)

- [ ] **Firestore**
  - [ ] Base de datos creada en región `us-central1`
  - [ ] Reglas `.github/firebase/firestore.rules` desplegadas
  - [ ] Modo Production confirmado (no Test Mode)

- [ ] **Cloud Storage**
  - [ ] Bucket creado en región `us-central1`
  - [ ] Reglas `.github/firebase/storage.rules` desplegadas

- [ ] **Flutter Integration**
  - [ ] `firebase_options.dart` con credenciales correctas
  - [ ] `main.dart` inicializa Firebase
  - [ ] Dependencias en `pubspec.yaml` (v2+)

- [ ] **Testing Pre-Deployment**
  - [ ] Test auth flow: signup → login → create dream
  - [ ] Test Firestore rules: allowed read/write patterns
  - [ ] Test Storage rules: audio upload/download
  - [ ] Test denied patterns: cross-user access blocked

---

## 8. Riesgos Identificados y Mitigación

| Riesgo | Severidad | Mitigación | Timeline |
|--------|-----------|-----------|----------|
| API Keys expuestas en código | 🔴 Alta | Usar firebase_options.dart + .gitignore | Inmediato |
| Cross-user data access | 🔴 Alta | Reglas ownership + uid validation | Sprint 2 QA |
| Quota limits en Auth | 🟡 Media | Monitoreo de dashboard, plan upgrade si necesario | Fase 3 |
| Storage bucket abuse | 🟡 Media | Tamaño máximo 100MB + content-type validation | Sprint 2 test |
| Firestore read costs | 🟡 Media | Índices optimizados, caché local Flutter | Fase 3 |
| Email spoofing | 🟡 Media | Email verification mandatory | Fase 3 |

---

## 9. Next Steps (Sprint 2)

1. **Implementation**
   - [ ] Implementar repositorios Flutter para Auth/Firestore/Storage
   - [ ] Crear servicios en `lib/features/auth/data/`
   - [ ] Conectar UI de registration/login

2. **Testing**
   - [ ] Pruebas unitarias de reglas Firestore (en Console o Firebase Emulator)
   - [ ] Pruebas E2E de acceso denegado cross-user
   - [ ] Validar tamaños de payload y latencias

3. **Monitoring**
   - [ ] Configurar alertas en Firebase Console para cuotas
   - [ ] Dashboard de Auth activos/errores
   - [ ] Logs de reglas denegadas

4. **Documentation**
   - [ ] Runbook operativo para depliegue de reglas
   - [ ] Guía de troubleshooting de errores comunes
   - [ ] Backup/restore procedures

---

## 10. Command Reference

### Firebase CLI Deployment
```bash
# Install Firebase CLI (si no está instalado)
npm install -g firebase-tools

# Login a Firebase
firebase login

# Desplegar reglas
firebase deploy --only firestore:rules,storage

# Ver estado actual
firebase deploy --dry-run

# Listar proyectos
firebase projects:list
```

### Testing Reglas Localmente (Emulator)
```bash
# Iniciar emulator suite
firebase emulators:start

# Ejecutar tests
firebase emulators:exec "npm test"
```

---

## 11. Contact & Escalation

**Responsable:** Firebase Backend Security Agent  
**Repo:** `.github/agents/firebase-backend-security.agent.md`  
**Runbook:** `.github/docs/guides/firebase-backend-runbook.md`  
**Lifecycle History:** `.github/agents/contexts/shared/shared-lifecycle-history.md`

Para cambios posteriores:
1. Consultar `.github/agents/contexts/shared/shared-app-context.md` para contexto
2. Actualizar reglas en archivos `.rules`
3. Registrar cambio en lifecycle history
4. Desplegar con validación pre/post

---

## Appendix: Example Flutter Integration Code

### Initialize Firebase
```dart
// lib/main.dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

### Create User Profile in Firestore (After Auth Signup)
```dart
// After Firebase Auth user creation
final user = FirebaseAuth.instance.currentUser;

await FirebaseFirestore.instance
    .collection('users')
    .doc(user!.uid)
    .set({
      'displayName': user.displayName ?? 'Dream Journaler',
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'aiEnabled': false, // Default off until Fase 3
      'timezone': 'UTC',
    });
```

### Upload Dream Audio to Storage
```dart
// Stream audio file to Storage
final audioFile = File(audioFilePath);
final storageRef = FirebaseStorage.instance
    .ref()
    .child('users/${user.uid}/dreams/$dreamId/audio.m4a');

await storageRef.putFile(audioFile);
```

### Read User Dreams with Ownership Check
```dart
// Query dreams (Firestore rules ensure ownership)
final dreamsSnapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .collection('dreams')
    .orderBy('dreamDate', descending: true)
    .get();
```

---

**Documento generado:** 2026-04-30  
**Versión:** 1.0  
**Última actualización:** Firebase Phase 2 Setup Initial Release
