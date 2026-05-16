# Sprint 2 Status Report

Sprint: 2 (Fase 2 - Desarrollo del Core)
Estado: Planificado

## Objetivo del sprint
Construir incremento funcional donde el usuario puede autenticarse, crear/leer/editar/eliminar sueños y ver datos persistentes en Firestore de forma segura.

## Entregable esperado
App Flutter compilable para Android, iOS y Web con flujo end-to-end de autenticación y gestión de diario textual.

## Criterios de aceptación
- [ ] Usuario se registra y loguea sin errores
- [ ] Sesión persiste tras cierre/reapertura de app
- [ ] CRUD de sueños funciona completamente
- [ ] Datos sincronizados en Firestore en tiempo real
- [ ] Reglas de seguridad activas y validadas
- [ ] App compila sin errores en Android, iOS, Web
- [ ] No hay deuda técnica bloqueante para Fase 3

---

## Pendiente de confirmar por Product Owner (bloqueante)

- [ ] Confirmar modelo de datos (campos de dreams, colecciones)
- [ ] Confirmar escala de mood (1-5 ó 1-10)
- [ ] Confirmar campos editables en Perfil
- [ ] Confirmar si Firebase ya existe o se crea proyecto nuevo
- [ ] Proporcionar credenciales de Firebase si ya existe

---

## Tareas pendientes por agente

### Firebase Backend Security Agent
- [ ] Crear/configurar proyecto Firebase
- [ ] Configurar Firebase Auth (email/password)
- [ ] Crear colecciones en Firestore (users, dreams, insights)
- [ ] Escribir y validar reglas de seguridad
- [ ] Documentar estructura de datos

### Flutter UX App Agent
- [ ] Setup inicial: dependencias y estructura de carpetas
- [ ] Configurar GoRouter y navegación
- [ ] Pantallas de autenticación (Login + Registro)
- [ ] Pantalla Home con acceso a nueva entrada
- [ ] Formulario Nueva Entrada (texto, fecha, mood)
- [ ] Lista cronológica de sueños
- [ ] Detalle y edición de sueño
- [ ] Pantalla Perfil (ver email, editar nombre, logout)

### Infra Mobile Firebase AI
- [ ] Instalar dependencias Firebase en pubspec.yaml
- [ ] Configurar entorno dev/prod
- [ ] Configurar google-services.json para Android
- [ ] Configurar GoogleService-Info.plist para iOS
- [ ] Setup GitHub Actions para builds automáticos
- [ ] Validar compilación en Android, iOS, Web

---

## Dependencias entre agentes
- Firebase Backend debe terminar Auth + Firestore antes de que Flutter UX conecte datos reales.
- Flutter UX puede avanzar con mocks hasta que Backend esté listo.
- Infra debe tener Google Services configurado antes de que Flutter UX finalice.

## Hitos de validación

| Hito | Validación |
|------|-----------|
| Firebase Backend listo | Auth funciona, Firestore creado, reglas activas |
| Flutter UX base lista | Proyecto compila, rutas y pantallas navegables |
| Conexión completa | Flutter conecta a Firebase real, CRUD funciona |
| Builds validados | APK, iOS, Web compilables sin errores |
| Demo funcional | Registro → login → crear sueño → ver en lista |

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|--------|-----------|
| Cambios en esquema de datos de Fase 1 | Media | Alto | Congelar modelo antes de iniciar Sprint 2 |
| Firebase Auth bloquea Flutter UX | Baja | Medio | Flutter trabaja con mocks hasta que Backend esté listo |
| Google Services mal configurado | Baja | Alto | Infra valida credenciales de forma continua |
| Dependencias Flutter incompatibles | Baja | Medio | Validar pubspec.yaml antes del sprint |
| CI/CD falla | Media | Medio | Validar GitHub Actions con PRs de prueba |


## Entregable esperado
App Flutter compilable para Android, iOS con flujo end-to-end de autenticación y gestión de diario textual.

## Criterios de aceptación
- ✓ Usuario se registra y loguea sin errores
- ✓ Sesión persiste tras cierre/reapertura de app
- ✓ CRUD de sueños funciona completamente
- ✓ Datos sincronizados en Firestore en tiempo real
- ✓ Reglas de seguridad activas y validadas
- ✓ App compila sin errores en Android, iOS
- ✓ No hay deuda técnica bloqueante para Fase 3

## Asignación de agentes y tareas

### Agente 1: Firebase Backend Security Agent
**Responsabilidad:** Configurar Backend seguro con Auth y Firestore.

**Tareas:**
1. Crear/configurar proyecto Firebase (si no existe).
   - Validación: Firebase console accesible
2. Configurar Firebase Auth (email/password).
   - Validación: Registro y login funcionan en emulador
3. Crear colecciones en Firestore.
   - users/{uid}/
   - users/{uid}/dreams/{dreamId}
   - users/{uid}/insights/{insightId}
   - Validación: Estructura visible en Firestore console
4. Escribir y validar reglas de seguridad.
   - Autenticación requerida.
   - Cada usuario solo ve sus datos.
   - Storage rules para audio (preparar para Fase 3).
   - Validación: Reglas de prueba en Firebase console pasan
5. Documentar estructura de datos y credenciales.
   - Validación: README con setup backend actualizado

---

### Agente 2: Flutter UX App Agent
**Responsabilidad:** Implementar UI, navegación y pantallas.

**Tareas (con dependencia de Firebase Backend):**
1. Setup inicial del proyecto Flutter.
   - Instalación de dependencias (firebase, go_router, etc.)
   - Estructura de carpetas (lib/app, lib/features, lib/shared)
   - Estimado: 2 horas
   - Validación: Proyecto compila sin errores
2. Configurar GoRouter y navegación.
   - Rutas principales: /auth, /home, /dream/create, /dream/:id, /profile
   - Estados de pantalla (loading, error, content)
   - Estimado: 3 horas
   - Validación: Navegación funciona entre pantallas en emulador
3. Pantallas de autenticación (Login + Registro).
   - Campos: email, contraseña, confirmación
   - Validaciones de entrada
   - Validación: Proyecto compila sin errores
2. Configurar GoRouter y navegación.
   - Rutas principales: /auth, /home, /dream/create, /dream/:id, /profile
   - Estados de pantalla (loading, error, content)
   - Validación: Navegación funciona entre pantallas en emulador
3. Pantallas de autenticación (Login + Registro).
   - Campos: email, contraseña, confirmación
   - Validaciones de entrada
   - Manejo de errores (usuario existe, contraseña débil, etc.)
   - Validación: Firebase Auth se dispara desde UI
4. Pantalla Home.
   - Botón flotante para nueva entrada
   - Acceso a Perfil
   - Preview de últimos sueños
   - Validación: Botones navegan correctamente
5. Formulario Nueva Entrada.
   - Campo de texto largo (descripción del sueño)
   - Selector de fecha/hora
   - Picker de mood (1-5)
   - Botones guardar/cancelar
   - Validación de campos obligatorios
   - Validación: Formulario enviable y datos se escriben en Firestore
6. Lista de Sueños.
   - Scroll vertical de sueños cronológicos
   - Preview de cada sueño (fecha, mood, primeras palabras)
   - Tap para ir a detalle
   - Estado vacío (sin sueños)
   - Validación: Lee datos de Firestore en tiempo real
7. Detalle y Edición de Sueño.
   - Lectura completa del sueño
   - Botones de editar/eliminar
   - Confirmación antes de eliminar
   - Formulario de edición similar a crear
   - Validación: Cambios se sincronizan en Firestore
8. Pantalla Perfil.
   - Mostrar email del usuario
   - Botón de logout
   - Campos editables (nombre, timezone)
   - Validación: Logout termina sesión y vuelve a Login
   - cloud_firestore
   - go_router
   - Otros: freezed, riverpod (si se usa para estado)
   - Estimado: 1 hora
   - Validación: `flutter pub get` sin errores
2. Configurar configuración por entorno (dev/prod).
   - Variables de entorno en .env
   - Inicialización diferenciada de Firebase
   - Estimado: 2 horas
   - Validación: App inicia con config correcta en ambos entornos
3. Configurar Google Services para Android.
   - google-services.json en android/app
   - Estimado: 1 hora
   - Validación: Android build incluye credenciales
4. Configurar GoogleService-Info.plist para iOS.
   - Descarga desde Firebase console
   - Integración en Xcode
   - Validación: `flutter pub get` sin errores
2. Configurar configuración por entorno (dev/prod).
   - Variables de entorno en .env
   - Inicialización diferenciada de Firebase
   - Validación: App inicia con config correcta en ambos entornos
3. Configurar Google Services para Android.
   - google-services.json en android/app
   - Validación: Android build incluye credenciales
4. Configurar GoogleService-Info.plist para iOS.
   - Descarga desde Firebase console
   - Integración en Xcode
   - Validación: iOS build incluye credenciales
5. Setup de GitHub Actions para builds automáticos.
   - Trigger: push a main
   - Build Android APK
   - Build iOS App
   - Build Web
   - Secretos: FIREBASE_TOKEN, etc.
   - Validación: Workflows ejecutan sin errores en PR
6. Validar compilación multiplataforma.
   - Android: `flutter build apk`
   - iOS: `flutter build ios` (simulador)
   - Web: `flutter build web`
   - Validación: Binarios compilables sin advertenciasglas borrador |
| 2026-05-16 | Flutter UX inicio | Proyecto compila, rutas funcionan, UI con mocks |
| 2026-05-18 | Conexión completa | Flutter conecta a Firebase real, CRUD funciona |
| 2026-05-21 | Builds validados | APK, iOS, Web compilables sin errores |
| 2026-05-24 | Demo funcional | End-to-end: registro → login → crear sueño → ver en lista |

## Riesgos y planes de mitigación que Flutter finalice.

## Hitos de validación

| Hito | Validación |
|------|-----------|
| Firebase Backend listo | Auth funciona, Firestore creado, reglas borrador |
| Flutter UX inicio | Proyecto compila, rutas funcionan, UI con mocks |
| Conexión completa | Flutter conecta a Firebase real, CRUD funciona |
| Builds validados | APK, iOS, Web compilables sin errores |
| Demo funcional | End-to-end: registro → login → crear sueño → ver en lista |

## Riesgos y planes de mitigación

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|--------|-----------|
| Cambios en esquema de datos de Fase 1 | Media | Alto | Congelar modelo de datos antes de iniciar Sprint 2 |
| Firebase Auth más lento de lo estimado | Baja | Medio | Backend comienza primero si es necesario |
| Google Services no configura correctamente | Baja | Alto | Infra valida credenciales continuo |
| Dependencias Flutter incompatibles | Baja | Medio | Testear pubspec.yaml antes del sprint |
| Build CI/CD falla | Media | Medio | Validar GitHub Actions continuo con PRs |

## Entradas requeridas del Product Owner (tú)

**Antes de iniciar Sprint 2:**
- [ ] Confirmar modelo de datos de Fase 1 (campos de dreams, colecciones)
- [ ] Confirmar escala de mood (1-5 ó 1-10)
- [ ] Confirmar lista de campos editables en Perfil
- [ ] Confirmar si Firebase ya existe o creo proyecto nuevo
- [ ] Proporcionar credenciales de Firebase (si existe) o autorizar creación

**Durante el sprint:**
- [ ] Review de mockups de UI
- [ ] Review de funcionalidad CRUD
- [ ] Feedback en demo de cierre

## Próximos pasos
1. Confirmar decisiones de Fase 1 (datos, UX, Firebase).
2. Crear backlog técnico detallado en GitHub Projects / Jira.
3. Kickoff de Sprint 2 con reunión de 30 min con agentes.
4. Ejecución en paralelo de tareas por agente.
5. Validaciones continuas según avanza el sprint.
