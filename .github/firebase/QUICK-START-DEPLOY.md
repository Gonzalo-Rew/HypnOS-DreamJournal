# Firebase Phase 2 - Quick Start Deployment

**Proyecto:** Hypnos Dream Journal  
**Duración estimada:** 10 minutos  
**Requisitos:** Firebase CLI, acceso a GCP Console

---

## 1. Pre-requisitos

### ✅ Verificar que está listo
```bash
# Verificar Firebase CLI
firebase --version
# Output esperado: firebase-tools/x.x.x

# Verificar Node.js
node --version
# Output esperado: v18.x.x o superior
```

### ⚠️ Si Firebase CLI NO está instalado
```bash
npm install -g firebase-tools
firebase login
```

---

## 2. Desplegar Reglas de Seguridad (5 minutos)

### Opción A: Via Firebase CLI (Recomendado)

```bash
# 1. Navegar al directorio del proyecto
cd c:\Users\ludig\Desktop\hypnos_dreamjournal

# 2. Seleccionar proyecto Firebase
firebase use hypnos-deamjournal

# 3. Desplegar reglas
firebase deploy --only firestore:rules,storage

# Output esperado:
# ✔ Deploy complete!
# 
# Project Console: https://console.firebase.google.com/project/hypnos-deamjournal
```

### Opción B: Via Firebase Console (Manual)

#### Firestore Rules
1. Ir a: **Firebase Console** → **hypnos-deamjournal** → **Firestore Database** → **Rules**
2. Reemplazar contenido con: `.github/firebase/firestore.rules`
3. Click **Publish**

#### Storage Rules
1. Ir a: **Firebase Console** → **hypnos-deamjournal** → **Storage** → **Rules**
2. Reemplazar contenido con: `.github/firebase/storage.rules`
3. Click **Publish**

---

## 3. Verificar Despliegue (2 minutos)

### Validar Firestore Rules
```bash
firebase deploy --dry-run --only firestore:rules
```

**Output esperado:**
```
i Cloud Firestore Rules will update upon next deploy.
```

### Validar Storage Rules
```bash
firebase deploy --dry-run --only storage
```

**Output esperado:**
```
i Cloud Storage Bucket Rules will update upon next deploy.
```

---

## 4. Configurar Authentication (3 minutos)

### Email/Password
1. **Firebase Console** → **Authentication** → **Sign-in method**
2. Habilitar **Email/Password**
   - ✅ Email enumeration protection: ON
   - ✅ Create (sign-up): ENABLED

3. Guardar

### (Opcional) Email Verification Template
1. **Authentication** → **Templates**
2. Ir a **Verification email**
3. Personalizar mensaje (opcional)
4. Guardar

---

## 5. Verificar Credenciales Flutter (1 minuto)

### En el archivo `lib/firebase_options.dart`

```dart
// ✅ Verificar que contiene:
DefaultFirebaseOptions.android
  - apiKey: AIzaSyB0_GKL2j4N3ztvu2gvGl9C80TZ4GWVjZo
  - projectId: hypnos-deamjournal
  - storageBucket: hypnos-deamjournal.firebasestorage.app

DefaultFirebaseOptions.ios
  - apiKey: AIzaSyAz50whvs0gcYk1AtOrfSxrIw0WikhndB0
  - projectId: hypnos-deamjournal
  - storageBucket: hypnos-deamjournal.firebasestorage.app
```

---

## 6. Testing Quick Validation (5 minutos)

### Test 1: User puede crear su perfil
```
Precondición: Usuario autenticado (uid = ABC123)
Operación: CREATE /users/ABC123
Data: { displayName, email, createdAt, aiEnabled, timezone }
Resultado esperado: ✅ PERMITIDO
```

### Test 2: User NO puede leer perfil de otro
```
Precondición: Usuario A autenticado (uid = ABC123)
Operación: READ /users/XYZ789 (otro usuario)
Resultado esperado: ❌ DENEGADO
Razón: isOwner(uid) returns false
```

### Test 3: User puede subir audio
```
Precondición: Usuario autenticado, dream creado
Operación: WRITE /users/ABC123/dreams/DREAM1/audio.m4a
Content-Type: audio/mp4
Size: 5MB
Resultado esperado: ✅ PERMITIDO
```

### Test 4: User NO puede subir archivo > 100MB
```
Precondición: Usuario autenticado
Operación: WRITE /users/ABC123/dreams/DREAM1/audio.m4a
Size: 150MB
Resultado esperado: ❌ DENEGADO
Razón: isValidAudioSize() limita a 100MB
```

---

## 7. Post-Deployment Checklist

- [ ] Reglas de Firestore desplegadas (firebase deploy output)
- [ ] Reglas de Storage desplegadas (firebase deploy output)
- [ ] Email/Password habilitado en Authentication
- [ ] Firebase Console muestra "Production" (no Test Mode)
- [ ] Test de acceso permitido ejecutado ✅
- [ ] Test de acceso denegado ejecutado ✅
- [ ] Credenciales en firebase_options.dart verificadas
- [ ] Team notificado del despliegue exitoso

---

## 8. Rollback (Si algo falla)

### Revertir Reglas Firestore
```bash
# Restaurar última versión funcionando
firebase deploy --only firestore:rules --force

# O manualmente en Console: escribir regla permitisiva temporal
```

### Revertir Reglas Storage
```bash
firebase deploy --only storage --force
```

---

## 9. Monitoring Post-Deploy

### Firebase Console
1. **Firestore** → **Monitoring** → Ver operaciones
   - Buscar DENIED requests (deben ser 0 en operación normal)
   - Latencia promedio < 100ms

2. **Storage** → **Monitoring** → Ver operaciones
   - Buscar DENIED requests
   - Bytes transferidos monitorear

3. **Authentication** → **Dashboard**
   - Verificar usuarios creados
   - Errores de autenticación

---

## 10. Troubleshooting Común

### Error: "firebase: command not found"
```bash
# Solución: Instalar Firebase CLI
npm install -g firebase-tools
```

### Error: "Permission denied" en despliegue
```bash
# Solución: Verificar que tienes acceso al proyecto
firebase login
firebase projects:list
firebase use hypnos-deamjournal
```

### Error: "Rules validation failed"
```bash
# Solución: Verificar sintaxis del archivo .rules
# 1. Buscar errores de sintaxis JSON
# 2. Validar que closing braces/parens están completos
# 3. Copiar contenido exacto del archivo (sin caracteres extra)
```

### Error: "User A denied access"
```bash
# Esperado en tests de seguridad
# Verificar que el test está intentando acceso cross-user
# Esto es correcto - debe ser DENEGADO
```

---

## 11. Documentación para el Equipo

| Documento | Propósito | Audiencia |
|-----------|----------|----------|
| **PHASE2-SUMMARY.md** | Overview ejecutivo, riesgos, timeline | PM, Leads |
| **firebase-phase2-setup.md** | Guía detallada de configuración | Backend Lead |
| **security-validation-tests.md** | Test plan y casos de validación | QA, Dev |
| **flutter-backend-integration.md** | Código de integración Flutter | Frontend Dev |

---

## 12. Command One-Liner (Deploy Todo)

```bash
cd c:\Users\ludig\Desktop\hypnos_dreamjournal && firebase use hypnos-deamjournal && firebase deploy --only firestore:rules,storage
```

**Output esperado:**
```
✔ Deploy complete!

Project Console: https://console.firebase.google.com/project/hypnos-deamjournal/database/firestore/data
```

---

## 13. Verificación Final

Ejecutar este comando para confirmar que todo está activo:

```bash
firebase database:get . --project hypnos-deamjournal
```

O visitar Firebase Console: https://console.firebase.google.com/project/hypnos-deamjournal

---

**Deployment Date:** 2026-04-30  
**Version:** 1.0  
**Status:** ✅ READY TO DEPLOY

**Siguiente paso:** Iniciar Sprint 2 - Implementación de Backend en Flutter  
**Contacto:** Firebase Backend Security Agent
