# Fase 2 - Coordinación de Kickoff (Sprint 2)

Estado: Preparación de handoffs

## Objetivo de Fase 2
Construir el MVP funcional con autenticación, CRUD de sueños en texto e integración Firebase.

## Entregable esperado al cierre
- App Flutter compilable con flujo Auth -> Home -> CRUD de sueños.
- Datos persistentes en Firestore.
- Reglas de seguridad iniciales activas.

## Coordinación de agentes

### 1. Flutter UX App Agent
**Objetivo:** Implementar pantallas y navegación base.

**Handoff:**
- Objetivo: Crear estructura UI de 5 pantallas principales (Login, Registro, Home, Nueva entrada, Lista, Detalle, Perfil).
- Restricciones:
  - Captura de texto debe ser < 60 segundos en UX.
  - Estados vacíos y loading definidos.
  - Navegación con GoRouter.
- Archivos impactados: lib/app/, lib/features/auth, lib/features/dreams, lib/features/profile
- Criterio de validación: Pantallas navegables, estados visuales consistentes, sin lógica de negocio.

**Tareas principales:**
1. Setup GoRouter y estructura de rutas.
2. Pantalla de Login/Registro.
3. Pantalla Home con acceso a nueva entrada.
4. Formulario de nueva entrada (texto + fecha + mood picker).
5. Lista cronológica de sueños.
6. Detalle de sueño.
7. Pantalla de Perfil.

### 2. Firebase Backend Security Agent
**Objetivo:** Configurar Auth, Firestore, reglas de seguridad.

**Handoff:**
- Objetivo: Configurar backend seguro con autenticación y base de datos.
- Restricciones:
  - Auth solo por email/contraseña en Fase 2 (OAuth futuro).
  - Reglas de Firestore: cada usuario solo ve sus datos.
  - Storage rules: acceso privado por UID.
- Archivos impactados: android/google-services.json, ios/Runner/GoogleService-Info.plist, firebase.json
- Criterio de validación: Auth funciona, Firestore almacena/recupera datos, reglas restrictivas activas.

**Tareas principales:**
1. Configurar Firebase Auth en proyecto.
2. Crear estructura de colecciones en Firestore (users, dreams).
3. Escribir reglas de seguridad para collections.
4. Probar autenticación end-to-end.
5. Documentar credenciales de entorno (sin exponerlas en repo).

### 3. Infra Mobile Firebase AI
**Objetivo:** Orquestar integración, entorno y CI/CD.

**Handoff:**
- Objetivo: Garantizar que Flutter + Firebase funciona en desarrollo, build y CI/CD.
- Restricciones:
  - Entorno local para desarrollo.
  - GitHub Actions para builds automáticos.
  - Secretos en GitHub Secrets (no en repo).
- Archivos impactados: pubspec.yaml, .github/workflows, android/, ios/, web/
- Criterio de validación: App compila localmente, CI/CD ejecuta sin errores, cambios son binarios verificables.

**Tareas principales:**
1. Instalar dependencias Firebase en pubspec.yaml.
2. Configurar configuración de entorno (dev/staging/prod).
3. Setup de CI/CD en GitHub Actions.
4. Validar compilación para Android, iOS, Web.

## Dependencias y orden
1. **Firebase Backend** inicia primero (configurar servicios en GCP/Firebase).
2. **Flutter UX** trabaja en paralelo (puede usar mocks).
3. **Infra** finaliza configuración CI/CD cuando ambas tareas avanzan.

## Entrada requerida del Product Owner (usuario)
**Antes de comenzar:**
1. Confirmar decisiones de Figma:
   - Colores y tipografía finales.
   - Layout de pantalla Nueva entrada (campos visibles, orden).
   - Pantalla Perfil: qué campos son editables.
2. Confirmar datos y reglas:
   - ¿Campos de sueño adicionales a los del esquema propuesto?
   - ¿Mood score en una escala 1-5 o 1-10?
3. Confirmar entorno:
   - ¿Proyecto Firebase ya creado o creo uno nuevo?
   - ¿Credenciales compartidas o distribuidas por agente?

## Próximos pasos
- [ ] Producto Owner confirma Figma y decisiones de datos.
- [ ] Firebase Backend Agent configura servicios.
- [ ] Flutter UX Agent comienza pantallas.
- [ ] Infra Agent configura CI/CD.
- [ ] Demo de Fase 2 listo cuando criterios de aceptacion se cumplan.

## Riesgos identificados
- Si Figma no está claro, Flutter UX retrabaja.
- Si Firebase no está configurado rápido, Flutter UX se bloquea en integración.
- Si CI/CD falla, no se valida build rápido.

**Mitigación:** Handoffs en paralelo donde sea posible, mocks en Flutter hasta tener backend.
