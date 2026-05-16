# Technical Integration Risk Assessment

**Project:** Hypnos Dream Journal  
**Phase:** 2  
**Sprint:** 2  
**Date:** 2026-04-30

---

## Overview
Este documento identifica riesgos y dependencias críticas para la integración de Flutter + Firebase + Google Gemini en la Fase 2 y posteriores.

---

## Riesgos críticos

### 1. Firebase Configuration (ALTA PRIORIDAD)
**Riesgo:** Google-services.json / GoogleService-Info.plist faltantes o desactualizados
- **Impacto:** App no se compila o falla al inicializar Firebase
- **Mitigación:** 
  - ✅ Archivos descargados y colocados en paths correctos
  - ✅ Verificar SHA-1 de certificado Android
  - ✅ Verificar bundle ID en iOS
- **Bloquea:** Todo desarrollo hasta que Firebase inicie correctamente
- **Validación:** 
  ```bash
  flutter run -v
  # Verificar logs: "I/Firebase: Firebase setup is complete"
  ```

### 2. Firebase Firestore Collections & Security Rules (ALTA PRIORIDAD)
**Riesgo:** Collections no existen o reglas de seguridad son demasiado restrictivas
- **Impacto:** Operaciones CRUD fallan, app cae en runtime
- **Mitigation:**
  - [ ] Crear collections en Firestore: users, dreams, insights
  - [ ] Definir indexes compuestos para queries con múltiples campos
  - [ ] Configurar reglas iniciales permisivas para desarrollo
  - [ ] Documentar reglas de seguridad definitivas antes de producción
- **Bloquea:** Sprint 3 cuando se implemente Dream CRUD
- **Validación:** 
  ```bash
  # Verificar en Firebase Console > Firestore
  # Collections creadas: users, dreams, insights
  ```

### 3. Audio Storage & Permissions (MEDIA)
**Riesgo:** Firebase Storage bucket no configurado o permisos insuficientes
- **Impacto:** Grabación de audio falla, upload a Storage falla
- **Mitigación:**
  - [ ] Habilitar Storage en Firebase project
  - [ ] Configurar path `/dreams/audio` con reglas de seguridad
  - [ ] Solicitar permisos en app (record, microphone)
  - [ ] Verificar que Storage rules permiten upload autenticado
- **Bloquea:** Fase 3 (audio capture feature)
- **Validación:** 
  ```bash
  # Verificar en Firebase Console > Storage
  # Bucket activo y path /dreams/audio accesible
  ```

### 4. Google Gemini API Key Management (ALTA PRIORIDAD)
**Riesgo:** API key compartida en código fuente, falta de rate limiting, quota excedida
- **Impacto:** Costo impredecible, exposición de credencial, servicio bloqueado
- **Mitigación:**
  - [ ] NO incluir API key en código fuente
  - [ ] Usar Cloud Functions como intermediario para llamadas a Gemini
  - [ ] Implementar rate limiting por usuario
  - [ ] Monitorear usage en Google Cloud Console
  - [ ] Considerar modelo de facturación pagado con alertas
- **Bloquea:** Fase 3+ (AI analysis feature)
- **Validación:** 
  ```bash
  # Verificar que API key NO está en .dart o pubspec.yaml
  # API key debe venir via Cloud Function
  ```

### 5. Authentication Flow Complexity (MEDIA)
**Riesgo:** Sesión de usuario se pierde en hot reload, estado inconsistente
- **Impacto:** Usuario vuelve a login inesperadamente, UX confusa
- **Mitigación:**
  - [ ] Implementar `authStateChanges()` stream correctamente
  - [ ] Usar Provider para persistencia de estado de auth
  - [ ] Guardar token refresh en secure storage (local_auth)
  - [ ] Testear hot reload/app kill scenarios
- **Bloquea:** Sprint 2 final (auth screens)
- **Validación:** 
  ```bash
  # Test: Login > hot reload > verificar que sigue logged in
  # Test: Login > kill app > reabrir > verificar que sigue logged in
  ```

### 6. Speech-to-Text Platform Differences (MEDIA)
**Riesgo:** STT behaves diferente en Android vs iOS, idioma no soportado
- **Impacto:** Transcripción falla o es inexacta en una plataforma
- **Mitigación:**
  - [ ] Implementar fallback a texto manual si STT falla
  - [ ] Testear en dispositivos reales (no solo emulador)
  - [ ] Configurar idioma correctamente
  - [ ] Manejo de errores robusto
- **Bloquea:** Fase 3 (audio capture)
- **Validación:** 
  ```bash
  # Test: Android device + iOS device
  # Verificar transcripción en ambas plataformas
  ```

### 7. Cloud Functions Cold Start (PERFORMANCE)
**Riesgo:** First call a Cloud Function tarda > 10 segundos (cold start)
- **Impacto:** UX pobre si user espera resultado de Gemini análisis
- **Mitigación:**
  - [ ] Implementar Cloud Tasks para procesamiento async
  - [ ] Usar Cloud Scheduler para keep-alive de Functions
  - [ ] Diseñar UX con indicador de "processing" no bloqueante
  - [ ] Considerar cached results si entrada duplicada
- **Bloquea:** Fase 3 final (AI analysis)
- **Validación:** 
  ```bash
  # Monitorear latencia en Cloud Functions logs
  # Optimizar si > 5 segundos
  ```

### 8. iOS Local Auth Permissions (COMPLIANCE)
**Riesgo:** Biometric auth no solicita permisos correctamente, falla en iOS
- **Impacto:** Biometric auth no funciona, app puede ser rechazada en App Store
- **Mitigación:**
  - [ ] Configurar `NSFaceIDUsageDescription` en Info.plist
  - [ ] Configurar `NSBiometricUsageDescription` si aplica
  - [ ] Testear en iOS device real (Face ID / Touch ID)
  - [ ] Proporcionar fallback a password
- **Bloquea:** Fase 3 (biometric feature)
- **Validación:** 
  ```bash
  # iOS: Build on device, verificar prompt de permiso
  # Verificar Info.plist en Xcode
  ```

---

## Dependencias bloqueantes

### Sprint 2 (Actual)
| Dependencia | Estado | Risk | Acción |
|---|---|---|---|
| Firebase Core + Auth | ✅ Ready | LOW | Validar en `flutter run` |
| Firestore collections | ⚠️ Pending | HIGH | Crear en Firebase Console |
| Data layer (models, repos, services) | ✅ Ready | LOW | Completado |
| State management (Provider) | ✅ Ready | LOW | Completado |
| pubspec.yaml actualizado | ✅ Ready | LOW | Actualizado |

### Sprint 3 (Dream CRUD)
| Dependencia | Estado | Risk | Acción |
|---|---|---|---|
| Firestore security rules | ⚠️ Pending | HIGH | Diseñar + implementar |
| Audio recording (record package) | ✅ Ready | LOW | Testear permisos |
| Storage bucket para audio | ⚠️ Pending | HIGH | Configurar en Firebase |
| Permissions handler | ✅ Ready | LOW | Completado |

### Fase 3 (AI + Speech)
| Dependencia | Estado | Risk | Acción |
|---|---|---|---|
| Google Gemini API | ⚠️ Pending | HIGH | Configurar API key management |
| Cloud Functions intermediaria | ⚠️ Pending | HIGH | Diseñar + implementar |
| Speech-to-text (speech_to_text) | ✅ Ready | LOW | Testear en device real |
| Biometric auth | ⚠️ Pending | MEDIA | iOS permissions |

---

## Checklists de validación

### Post-Sprint 2 (Before merge to main)
- [ ] Firebase initializa sin errores (`flutter run -v`)
- [ ] AuthRepository.signUp funciona end-to-end
- [ ] AuthRepository.signIn funciona end-to-end
- [ ] User document se guarda en Firestore
- [ ] App no crashea en hot reload post-login
- [ ] Code analysis pasa (`flutter analyze`)
- [ ] No hay imports no usados
- [ ] README.md + SETUP_GUIDE.md actualizados

### Pre-Sprint 3
- [ ] Firestore collections creadas (users, dreams, insights)
- [ ] Firestore security rules documentadas (borrador)
- [ ] Storage bucket configurado
- [ ] DreamRepository methods testeados en emulador
- [ ] Audio permissions funciona en Android + iOS
- [ ] Decisions de navigation (GoRouter) documentadas

### Pre-Fase 3
- [ ] Cloud Functions structure definida
- [ ] Gemini API key strategy approved
- [ ] Rate limiting strategy documentada
- [ ] Cost estimation para Gemini done
- [ ] STT fallback strategy diseñada

---

## Monitoreo post-deployment

### Firebase Metrics to track
- Firestore read/write quota usage
- Storage bandwidth usage
- Firebase Auth active users
- Cloud Function invocations + latency
- Error rates por operación

### App Metrics to track
- Auth success/failure rates
- Dream creation success rate
- Audio upload success rate
- Gemini API latency
- App crash rate

---

## Escalación y Contingencia

### Si Firebase falla en producción
1. Rollback a última versión estable
2. Comunicar a users via app banner
3. Investigar logs en Firebase Console
4. Contactar Firebase Support si persiste

### Si Gemini API quota se excede
1. Desactivar AI analysis feature
2. Mostrar error amable al user
3. Considerar upgrade de plan
4. Implementar better rate limiting

### Si Cloud Storage se llena
1. Implementar archive policy para audio viejo
2. Notificar users a borrar grabaciones
3. Considerar storage upgrade
4. Implementar cleanup automation

---

## Propuestas de mejora

1. **Implementar Firebase Emulator** para desarrollo local (offline testing)
2. **Crear observability layer** centralizada para logging/monitoring
3. **Implementar feature flags** via Firebase Remote Config
4. **Setup CI/CD pipeline** con GitHub Actions
5. **Implementar automated testing** (unit + widget + integration)

---

**Owner:** Infra Mobile Firebase AI Agent  
**Última actualización:** 2026-04-30
