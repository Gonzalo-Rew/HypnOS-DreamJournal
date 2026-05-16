# Firebase Security Validation Tests

**Proyecto:** Hypnos Dream Journal  
**Fase:** 2 - Pre-deployment Validation  
**Fecha:** 2026-04-30

---

## Objetivo

Validar que las reglas de Firestore y Storage cumplen con los patrones de acceso esperados:
- ✅ Permitidos: acceso del propietario
- ❌ Denegados: acceso cross-user, acceso anónimo

---

## 1. Firestore Rules Test Cases

### 1.1 User Document Tests

#### ✅ TEST: User A read su propio perfil
```
Path: /users/{uidA}
Auth: uidA (autenticado)
Operation: READ
Expected: ALLOW
Reason: isOwner(uid) returns true
```

#### ❌ TEST: User A read perfil de User B
```
Path: /users/{uidB}
Auth: uidA (autenticado)
Operation: READ
Expected: DENY
Reason: isOwner(uidB) returns false (uidA != uidB)
```

#### ❌ TEST: User anonimo read perfil
```
Path: /users/{uidA}
Auth: null (no autenticado)
Operation: READ
Expected: DENY
Reason: isAuthenticated() returns false
```

#### ✅ TEST: User A create su propio perfil (signup)
```
Path: /users/{uidA}
Auth: uidA
Operation: CREATE
Data: {
  displayName: "Alice",
  email: "alice@example.com",
  createdAt: timestamp,
  aiEnabled: false,
  timezone: "UTC"
}
Expected: ALLOW
Reason: isOwner(uid) && hasRequiredUserFields() && isValidUserData()
```

#### ❌ TEST: User A create perfil para User B
```
Path: /users/{uidB}
Auth: uidA
Operation: CREATE
Expected: DENY
Reason: isOwner(uidB) returns false
```

#### ❌ TEST: User A update email de su perfil
```
Path: /users/{uidA}
Auth: uidA
Operation: UPDATE
Data: {
  ...old_data...
  email: "newemail@example.com"  // Intentar modificar
}
Expected: DENY
Reason: request.resource.data.email != resource.data.email (email no puede cambiar)
```

#### ✅ TEST: User A update aiEnabled
```
Path: /users/{uidA}
Auth: uidA
Operation: UPDATE
Data: {
  ...old_data...
  aiEnabled: true  // Cambiar de false a true
  updatedAt: new_timestamp  // Actualizar timestamp (opcional en user)
}
Expected: ALLOW
Reason: email y createdAt no cambian, otros campos son actualizables
```

---

### 1.2 Dream Document Tests

#### ✅ TEST: User A read su propio dream
```
Path: /users/{uidA}/dreams/{dreamIdA}
Auth: uidA
Operation: READ
Expected: ALLOW
Reason: isOwner(uidA) && Firestore subcollection inherits parent rules
```

#### ❌ TEST: User A read dream de User B
```
Path: /users/{uidB}/dreams/{dreamIdB}
Auth: uidA
Operation: READ
Expected: DENY
Reason: isOwner(uidB) returns false
```

#### ✅ TEST: User A create nuevo dream
```
Path: /users/{uidA}/dreams/{dreamIdA_new}
Auth: uidA
Operation: CREATE
Data: {
  title: "Vivid Dream",
  text: "Detailed description...",
  dreamDate: timestamp,
  createdAt: timestamp,
  updatedAt: timestamp,
  moodScore: 7,
  tags: ["anxiety", "family"],
  hasAudio: false,
  audioPath: null,
  transcription: null,
  aiSummary: null
}
Expected: ALLOW
Reason: isOwner(uid) && hasRequiredDreamFields() && isValidDreamData()
```

#### ❌ TEST: User A create dream con moodScore = 15 (fuera de rango)
```
Path: /users/{uidA}/dreams/{dreamIdA_new}
Auth: uidA
Operation: CREATE
Data: {
  ...all_fields...
  moodScore: 15  // Rango válido: 0-10
}
Expected: DENY
Reason: isValidDreamData() valida 0 <= moodScore <= 10
```

#### ✅ TEST: User A update dream (cambiar texto)
```
Path: /users/{uidA}/dreams/{dreamIdA}
Auth: uidA
Operation: UPDATE
Data: {
  ...old_data...
  text: "Updated description...",
  updatedAt: new_timestamp  // timestamp > viejo
}
Expected: ALLOW
Reason: createdAt no cambia, updatedAt es más nuevo
```

#### ❌ TEST: User A update dream con updatedAt antiguo
```
Path: /users/{uidA}/dreams/{dreamIdA}
Auth: uidA
Operation: UPDATE
Data: {
  ...old_data...
  updatedAt: old_timestamp  // timestamp <= viejo
}
Expected: DENY
Reason: Regla requiere request.resource.data.updatedAt > resource.data.updatedAt
```

#### ✅ TEST: User A delete su dream
```
Path: /users/{uidA}/dreams/{dreamIdA}
Auth: uidA
Operation: DELETE
Expected: ALLOW
Reason: isOwner(uidA)
```

---

### 1.3 Insights Document Tests

#### ✅ TEST: User A read su propio insight
```
Path: /users/{uidA}/insights/{insightIdA}
Auth: uidA
Operation: READ
Expected: ALLOW
Reason: isOwner(uidA)
```

#### ✅ TEST: User A create insight
```
Path: /users/{uidA}/insights/{insightIdA_new}
Auth: uidA
Operation: CREATE
Data: {
  periodStart: timestamp_1,
  periodEnd: timestamp_2,  // > timestamp_1
  dominantEmotions: ["anxiety", "joy"],
  recurringTags: ["family", "work"],
  generatedAt: timestamp
}
Expected: ALLOW
Reason: isOwner(uid) && validación de estructura
```

#### ❌ TEST: User A create insight con periodEnd <= periodStart
```
Path: /users/{uidA}/insights/{insightIdA_new}
Auth: uidA
Operation: CREATE
Data: {
  periodStart: timestamp_2,
  periodEnd: timestamp_1,  // <= timestamp_2 (INVÁLIDO)
  ...other_fields...
}
Expected: DENY
Reason: isValidInsightData() valida periodStart < periodEnd
```

---

## 2. Cloud Storage Rules Test Cases

### 2.1 Audio File Upload/Download

#### ✅ TEST: User A upload audio para su dream
```
Path: /users/{uidA}/dreams/{dreamIdA}/audio.m4a
Auth: uidA
Operation: WRITE (create)
Content-Type: audio/mp4
Size: 5 MB
Expected: ALLOW
Reason: isOwnerByPath() && isAudioFile() && isValidAudioSize()
```

#### ❌ TEST: User A upload archivo no-audio
```
Path: /users/{uidA}/dreams/{dreamIdA}/audio.m4a
Auth: uidA
Operation: WRITE
Content-Type: application/pdf
Size: 1 MB
Expected: DENY
Reason: isAudioFile() valida content-type audio/* y extensión .m4a
```

#### ❌ TEST: User A upload audio > 100 MB
```
Path: /users/{uidA}/dreams/{dreamIdA}/audio.m4a
Auth: uidA
Operation: WRITE
Content-Type: audio/mp4
Size: 150 MB
Expected: DENY
Reason: isValidAudioSize() limita a 100 MB
```

#### ✅ TEST: User A download su audio
```
Path: /users/{uidA}/dreams/{dreamIdA}/audio.m4a
Auth: uidA
Operation: READ
Expected: ALLOW
Reason: isOwnerByPath()
```

#### ❌ TEST: User B download audio de User A
```
Path: /users/{uidA}/dreams/{dreamIdA}/audio.m4a
Auth: uidB
Operation: READ
Expected: DENY
Reason: isOwnerByPath() valida uid de ruta == auth.uid
```

#### ✅ TEST: User A delete su audio
```
Path: /users/{uidA}/dreams/{dreamIdA}/audio.m4a
Auth: uidA
Operation: DELETE
Expected: ALLOW
Reason: isOwnerByPath()
```

---

## 3. Manual Testing Checklist

### Pre-Deployment (Firebase Console)
- [ ] Crear usuario A en Firebase Auth (email: a@example.com, password: Test123)
- [ ] Crear usuario B en Firebase Auth (email: b@example.com, password: Test123)
- [ ] Crear documento manual en `/users/{uidA}` con campos requeridos

### Firestore Emulator Tests
```bash
# Iniciar emulador
firebase emulators:start --only firestore

# En consola de pruebas, validar acceso
# User A can read users/{uidA}
# User B CANNOT read users/{uidA}
# User C (anónimo) CANNOT read anything
```

### Flutter Integration Tests
```dart
// test/firebase_security_test.dart

void main() {
  setUpAll(() async {
    // Inicializar Firebase Emulator
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  });

  group('Firestore Security Rules', () {
    test('User A can read own profile', () async {
      // Implementar test
    });

    test('User A cannot read User B profile', () async {
      // Implementar test
    });

    test('User A cannot create dream for User B', () async {
      // Implementar test
    });
  });

  group('Storage Security Rules', () {
    test('User A can upload audio to own dream', () async {
      // Implementar test
    });

    test('User B cannot download User A audio', () async {
      // Implementar test
    });
  });
}
```

---

## 4. Validación Post-Deployment

### Métricas a monitorear
- ❌ Número de operaciones DENIED (deben ser 0 en operación normal)
- ⚠️ Latencia promedio de lectura: < 100ms
- ⚠️ Tasa de errores de autenticación: < 0.1%

### Alertas recomendadas
```
- Alert: Más de 10 DENIED en 1 minuto (posible ataque)
- Alert: Promedio de latencia > 500ms (posible problema de índices)
- Alert: Tasa de auth errors > 1% (credenciales comprometidas?)
```

---

## 5. Security Regression Test (Antes de cada release)

Ejecutar ANTES de desplegar cambios en reglas:

1. [ ] Validar que User A puede hacer CRUD en propios documents
2. [ ] Validar que User B NO puede acceder a datos de User A
3. [ ] Validar que datos anónimos son denegados
4. [ ] Validar tipos de datos no aceptan valores inválidos
5. [ ] Validar tamaños de archivo dentro de límites

---

**Última actualización:** 2026-04-30  
**Versión:** 1.0  
**Responsable:** Firebase Backend Security Agent
