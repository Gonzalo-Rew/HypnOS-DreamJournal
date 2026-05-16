# Shared Lifecycle History

Este archivo guarda un historial generico del proceso de vida de la aplicacion.
El objetivo es facilitar la redaccion futura del documento TFG con trazabilidad tecnica.

## Reglas de uso
- Aplica a todos los agentes actuales y futuros del proyecto.
- Registrar hitos relevantes despues de cambios significativos.
- Usar un formato breve, cronologico y verificable.
- No incluir secretos, credenciales ni datos sensibles.

## Formato de registro
- Fecha: YYYY-MM-DD
- Categoria: Arquitectura | Firebase | Auth | Firestore | Storage | Functions | CI/CD | Release | QA | Agentes
- Cambio: descripcion concreta de lo realizado
- Impacto: que mejora, corrige o habilita
- Evidencia: archivo(s), comando(s) o validacion asociada

## Historial
- Fecha: 2026-04-29
- Categoria: Agentes
- Cambio: Creacion de dos archivos compartidos para contexto global e historial de ciclo de vida.
- Impacto: Base comun para agentes actuales y futuros y mejor trazabilidad para el TFG.
- Evidencia: .github/agents/contexts/shared/shared-app-context.md, .github/agents/contexts/shared/shared-lifecycle-history.md

- Fecha: 2026-04-29
- Categoria: Arquitectura
- Cambio: Sintesis extrema del contexto funcional/tecnico de la app en shared-app-context.
- Impacto: Contexto mas corto, accionable y consistente para decisiones de todos los agentes.
- Evidencia: .github/agents/contexts/shared/shared-app-context.md

- Fecha: 2026-04-30
- Categoria: Firestore | Storage
- Cambio: Reemplazado modo test por reglas de seguridad reales en Firestore y Storage. firebase.json actualizado para referenciar los archivos de reglas. Creado firestore.indexes.json vacio.
- Impacto: Acceso denegado por defecto; cada usuario solo accede a sus propios documentos y archivos de audio. Validaciones basicas de campos en writes. Principio de minimo privilegio aplicado.
- Evidencia: firestore.rules, storage.rules, firestore.indexes.json, firebase.json

- Fecha: 2026-04-29
- Categoria: Agentes
- Cambio: Creacion de arquitectura multiagente coordinada con 4 agentes especialistas y un documento de coordinacion transversal.
- Impacto: Mejor reparto de responsabilidades, delegacion explicita por dominio y menor riesgo de solapamientos.
- Evidencia: .github/agents/flutter-ux-app.agent.md, .github/agents/firebase-backend-security.agent.md, .github/agents/qa-release.agent.md, .github/agents/data-insights.agent.md, .github/agents/contexts/shared/shared-agent-coordination.md

- Fecha: 2026-04-29
- Categoria: Agentes
- Cambio: Creacion de documentos operativos por dominio para UX, backend, QA y metrica, y actualizacion de agentes existentes para coordinacion.
- Impacto: Estandar operativo por agente y mayor consistencia de ejecucion entre tareas.
- Evidencia: .github/agents/contexts/specialized/flutter-ux-style-context.md, .github/docs/guides/firebase-backend-runbook.md, .github/docs/checklists/qa-release-checklist.md, .github/agents/contexts/specialized/data-insights-metric-context.md, .github/agents/infra-mobile-firebase-ai.agent.md, .github/agents/gestor-agentes-copilot.agent.md

- Fecha: 2026-04-29
- Categoria: Agentes
- Cambio: Refinamiento del contexto UX de Flutter con sistema visual completo (tokens, tipografia, movimiento), especificaciones por pantalla (Home, Captura, Analisis) y criterios de aceptacion UX.
- Impacto: Guia de implementacion front mas concreta y consistente con objetivo de captura < 60s y accesibilidad en uso nocturno.
- Evidencia: .github/agents/contexts/specialized/flutter-ux-style-context.md

- Fecha: 2026-04-29
- Categoria: Agentes
- Cambio: Creacion de un agente intermediario para coordinacion de desarrollo de software y toma de decisiones entre usuario y agentes especialistas.
- Impacto: Mejora la priorizacion tecnica, reduce ambiguedades de handoff y estandariza decisiones multi-dominio.
- Evidencia: .github/agents/software-decision-orchestrator.agent.md, .github/agents/contexts/shared/shared-agent-coordination.md, .github/agents/contexts/shared/shared-app-context.md

- Fecha: 2026-04-29
- Categoria: Arquitectura
- Cambio: Creacion de un documento operativo de planificacion de sprints con fases, criterios de salida y plantilla de validacion con Product Owner.
- Impacto: Estandariza el proceso incremental de entrega y validacion al cierre de cada sprint.
- Evidencia: .github/docs/plans/sprint-development-plan.md

- Fecha: 2026-04-29
- Categoria: Arquitectura
- Cambio: Inicio formal de Fase 1 con definicion de Sprint 1 y creacion del entregable base de analisis/diseno (prototipo, datos y arquitectura).
- Impacto: Se habilita ejecucion guiada del sprint con criterios de aceptacion y base tecnica para arrancar Fase 2 sin ambiguedad.
- Evidencia: .github/docs/plans/sprint-development-plan.md, .github/docs/reports/phase-1-analysis-design-deliverable.md

- Fecha: 2026-04-30
- Categoria: Firebase
- Cambio: Preparacion de infraestructura Firebase para Fase 2 con reglas de seguridad, documentacion y guia de integracion Flutter.
- Impacto: Backend seguro y listo para Sprint 2 con least-privilege access control, validacion de datos y ownership-based authorization.
- Evidencia: .github/firebase/firestore.rules, .github/firebase/storage.rules, .github/firebase/firebase-phase2-setup.md, .github/firebase/security-validation-tests.md, .github/firebase/flutter-backend-integration.md

- Fecha: 2026-04-30
- Categoria: Arquitectura
- Cambio: Creacion de estructura base Flutter con Repository Pattern, modelos de dominio, servicios Firebase, y capa de datos completa.
- Impacto: Infraestructura de código lista para implementación de features sin deuda técnica. Soporta modularización por features y reutilización de código.
- Evidencia: lib/ (estructura de carpetas, modelos, repositories, services), pubspec.yaml (dependencias actualizadas con Provider + GoRouter), SETUP_GUIDE.md, INTEGRATION_RISKS.md

- Fecha: 2026-04-30
- Categoria: Arquitectura
- Cambio: Definición de modelos de dominio Dart (User, Dream, Insight) con serialización Firestore y relaciones bidireccionales.
- Impacto: Contratos claros entre Data y Presentation layers. Facilita testing y elimina ambigüedad en transformación de datos.
- Evidencia: lib/data/models/ (user_model.dart, dream_model.dart, insight_model.dart)

- Fecha: 2026-04-30
- Categoria: Arquitectura
- Cambio: Implementación de FirebaseService wrapper, AuthRepository + DreamRepository con Result<T> pattern para manejo funcional de errores.
- Impacto: Abstracción de Firebase en interfaces reutilizables. Error handling robusto sin crashes inesperados.
- Evidencia: lib/data/services/firebase_service.dart, lib/data/repositories/ (auth_repository.dart, dream_repository.dart)

- Fecha: 2026-04-30
- Categoria: Arquitectura
- Cambio: Adición de extensiones Dart reutilizables (String, DateTime, List, Map) y utilidades compartidas (validadores, formateadores).
- Impacto: Código más legible, menos boilerplate, validaciones consistentes en toda la app.
- Evidencia: lib/shared/ (extensions/extensions.dart, utils/validators_formatters.dart)

- Fecha: 2026-04-30
- Categoria: Arquitectura
- Cambio: Documentación exhaustiva de estructura del proyecto, setup, dependencias y guía para desarrollador.
- Impacto: Onboarding más rápido, referencia clara de arquitectura, reduce preguntas de implementación.
- Evidencia: SETUP_GUIDE.md (instalación, estructura, modelos, servicios), INTEGRATION_RISKS.md (riesgos y dependencias bloqueantes)

- Fecha: 2026-04-30
- Categoria: Arquitectura
- Cambio: Identificación de riesgos críticos de integración: Firebase config, Firestore rules, Audio storage, Gemini API management, Auth persistence, STT diferencias, Cloud Functions cold start.
- Impacto: Mitiga sorpresas en sprint y documenta dependencias bloqueantes por fase.
- Evidencia: INTEGRATION_RISKS.md (8 riesgos críticos, checklists de validación, propuestas de mejora)

- Fecha: 2026-04-30
- Categoria: Firebase | Arquitectura | CI/CD
- Cambio: Hardening del arranque Flutter/Firebase para plataformas no configuradas (modo degradado sin crash), ajuste de compatibilidad en capa Dream para restaurar compilación estática y creación de workflow CI mínimo con pub get + analyze + test.
- Impacto: Sprint 2 habilitado con bootstrap robusto, menor riesgo de fallo en web/desktop sin config Firebase y validación automática base en pull requests.
- Evidencia: lib/app/bootstrap.dart, lib/main.dart, lib/firebase_options.dart, lib/features/dreams/presentation/, .github/workflows/flutter-ci.yml

- Fecha: 2026-04-30
- Categoria: Auth | Firestore | Storage
- Cambio: Implementado bloque backend base de Sprint 2 con esquema de usuarios/suenos alineado a Firestore, repositorios con acceso por uid autenticado y validacion moodScore 1-5.
- Impacto: Base backend funcional y endurecida con minimo privilegio para perfil y CRUD de suenos.
- Evidencia: lib/data/models/user_model.dart, lib/data/models/dream_model.dart, lib/data/repositories/auth_repository.dart, lib/data/repositories/dream_repository.dart, firestore.rules, storage.rules

- Fecha: 2026-04-30
- Categoria: Arquitectura | Auth | UX
- Cambio: Implementado bloque UI/UX de Sprint 2 con flujo navegable Auth -> Home -> Crear/Listar/Editar/Eliminar sueno -> Perfil, formularios con validaciones y estados loading/empty/error.
- Impacto: Flujo funcional end-to-end sobre repositorios existentes, habilitando uso real de auth y CRUD de suenos con configuracion de perfil y notificaciones.
- Evidencia: lib/main.dart, lib/app/app_routes.dart, lib/features/auth/presentation/, lib/features/home/presentation/, lib/features/dreams/presentation/, lib/features/profile/presentation/, comando `flutter analyze lib`

- Fecha: 2026-05-04
- Categoria: QA
- Cambio: Creacion de checklist de QA formal para Sprint 2 con 40 verificaciones en 9 bloques (entorno, auth, home, CRUD, perfil, seguridad y UI/resolucion) y criterio de aceptacion del Product Owner.
- Impacto: Proceso de validacion objetivo para cierre de Sprint 2 y trazabilidad del incremento entregado. Util como evidencia metodologica para TFG.
- Evidencia: .github/docs/checklists/qa-sprint-2-checklist.md

- Fecha: 2026-05-04
- Categoria: CI/CD
- Cambio: Creacion de guia de despliegue paso a paso para Android Studio con configuracion de 3 emuladores (resoluciones pequena, media y grande), instrucciones de ejecucion, prueba en dispositivo fisico y comandos de build debug/release.
- Impacto: Proceso de despliegue reproducible y documentado. Reduce friccion para iniciar validacion QA. Evidencia de proceso de desarrollo para TFG.
- Evidencia: .github/docs/guides/android-studio-deploy-guide.md

- Fecha: 2026-05-04
- Categoria: UX | Arquitectura
- Cambio: Implementacion de sistema de tema centralizado para Sprint 2 (tokens de color, tipografia, espaciados y radios) y aplicacion consistente en login, registro, home, lista/formulario/detalle de suenos y perfil.
- Impacto: Eliminacion de apariencia Material por defecto, mayor coherencia visual nocturna y CTA principal mas evidente por pantalla sin cambios de logica de negocio.
- Evidencia: lib/app/theme/, lib/main.dart, lib/features/auth/presentation/, lib/features/home/presentation/, lib/features/dreams/presentation/, lib/features/profile/presentation/, comprobacion estatica en archivos modificados.

- Fecha: 2026-05-05
- Categoria: Agentes | Arquitectura
- Cambio: Reorganizacion de .github separando agentes, contextos compartidos/especializados y documentos externos (guias, checklists, planes, estatus y reportes), con actualizacion de rutas de referencia.
- Impacto: Estructura mas entendible, menor mezcla de responsabilidades y mejor mantenibilidad para agentes actuales y futuros.
- Evidencia: .github/agents/README.md, .github/agents/contexts/, .github/docs/, .github/agents/*.agent.md, .github/firebase/*.md

- Fecha: 2026-05-07
- Categoria: Arquitectura | Audio | IA
- Cambio: Implementacion de AudioService para grabacion con record y subida a Firebase Storage bajo path users/{uid}/dreams/{dreamId}/audio.m4a.
- Impacto: Base de infraestructura de audio lista para grabacion, subida y borrado. Sin crash si Storage falla (fallback graceful).
- Evidencia: lib/data/services/audio_service.dart, lib/shared/errors/exceptions.dart (PermissionException)

- Fecha: 2026-05-07
- Categoria: IA | Arquitectura
- Cambio: Implementacion de GeminiService con analisis estructurado de suenos (sentimiento, categoria, emociones, personajes, lugares, temas, nota psicologica, resumen) y soporte para transcripcion multimodal por bytes.
- Impacto: Integracion limpia con Gemini 1.5 Flash sin acoplamiento directo en UI. Parsing de respuesta estructurado en DreamAnalysis.
- Evidencia: lib/data/services/gemini_service.dart

- Fecha: 2026-05-07
- Categoria: UX | Audio
- Cambio: Implementacion de AudioRecorderWidget (grabacion con cronometro y punto pulsante) y AudioPlayerWidget (slider + tiempos + play/pause desde URL remota) como widgets reutilizables.
- Impacto: Componentes de audio listos para integrarse en cualquier pantalla. Estado de grabacion y reproduccion encapsulado.
- Evidencia: lib/shared/widgets/audio_recorder_widget.dart, lib/shared/widgets/audio_player_widget.dart

- Fecha: 2026-05-07
- Categoria: UX | IA | Auth
- Cambio: Actualizacion de DreamFormScreen (seccion grabacion de audio), DreamDetailScreen (reproductor + transcripcion + bloque analisis IA con boton explicito) y ProfileScreen (campo clave Gemini API con obscure text, guardado en SharedPreferences).
- Impacto: Flujo end-to-end de Sprint 3 completo: grabacion -> subida Storage -> reproduccion -> analisis IA bajo demanda. Clave API nunca expuesta en Firestore.
- Evidencia: lib/features/dreams/presentation/dream_form_screen.dart, lib/features/dreams/presentation/dream_detail_screen.dart, lib/features/profile/presentation/profile_screen.dart, lib/core/config/app_settings.dart

- Fecha: 2026-05-07
- Categoria: Arquitectura | L10n
- Cambio: Extension de archivos de localizacion (app_en.arb, app_es.arb, app_localizations.dart, app_localizations_en.dart, app_localizations_es.dart) con 30 nuevas claves para Sprint 3 (grabadora, reproductor, analisis IA, clave Gemini).
- Impacto: Cobertura completa ES/EN de todas las cadenas del Sprint 3. Sin strings hardcoded en UI nueva.
- Evidencia: lib/l10n/

- Fecha: 2026-05-07
- Categoria: QA
- Cambio: Creacion del checklist de QA formal para Sprint 3 con 55 verificaciones en 10 bloques (entorno, permisos, grabacion, Storage, reproduccion, clave Gemini, analisis IA, seguridad, UI y regresion Sprint 2).
- Impacto: Proceso de validacion objetivo para cierre de Sprint 3. Pendiente ejecucion por Product Owner.
- Evidencia: .github/docs/checklists/qa-sprint-3-checklist.md

- Fecha: 2026-05-07
- Categoria: Agentes | Arquitectura
- Cambio: Eliminacion de documentos duplicados en .github/agents para mantener una sola fuente de verdad en .github/docs y reducir carga de contexto/tokens.
- Impacto: Estructura mas limpia, menor riesgo de inconsistencias entre copias y menor consumo de contexto en agentes.
- Evidencia: .github/agents/README.md, .github/docs/, .github/agents/*.agent.md

- Fecha: 2026-05-09
- Categoria: UX | Arquitectura | IA
- Cambio: Implementacion de Sprint 4 completo — Dashboard de estadisticas, toggle de IA en perfil y mejora de HomeScreen.
- Impacto: Fase 4 del roadmap completada. App funcional end-to-end con analisis de datos, visualizaciones y control de privacidad IA.
- Evidencia:
  - lib/features/dashboard/presentation/dashboard_screen.dart (nuevo) — 4 secciones: resumen numerico, LineChart mood evolution, BarChart suenos/semana, top categorias IA y top tags
  - lib/app/app_routes.dart — ruta /dashboard
  - lib/main.dart — DashboardScreen registrado en routes
  - lib/features/home/presentation/home_screen.dart — boton Dashboard, navegacion directa a DreamFormScreen
  - lib/core/config/app_settings.dart — getAiEnabled / setAiEnabled con SharedPreferences
  - lib/features/profile/presentation/profile_screen.dart — SwitchListTile "Analisis IA activado"
  - lib/features/dreams/presentation/dream_detail_screen.dart — carga _aiEnabled, muestra mensaje cuando IA desactivada
  - lib/l10n/app_en.arb + app_es.arb — 14 nuevas claves para dashboard y toggle IA
  - flutter analyze lib --no-fatal-infos -> EXIT 0
