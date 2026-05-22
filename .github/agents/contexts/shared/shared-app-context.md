# Shared App Context

Este archivo centraliza el contexto funcional y tecnico de la aplicacion.
Todos los agentes deben leerlo antes de proponer cambios y actualizarlo cuando el contexto base cambie.

## Reglas de uso
- Aplica a todos los agentes actuales y futuros del proyecto.
- Leer este archivo al inicio de cualquier tarea relevante.
- Actualizar solo cuando cambie informacion base de producto, arquitectura o entorno.
- Mantener entradas concretas y verificables.

## Identidad de la aplicacion
- Nombre: Hypnos Dream Journal
- Tipo: App mHealth de diario onirico y bienestar emocional
- Propuesta: pasar de interpretacion simbolica a analisis de patrones habitos-sueno basado en datos

## Norte del producto (ultra sintetico)
- Problema: el diario tradicional no permite detectar patrones a largo plazo.
- Solucion: registro rapido por texto/voz + analitica IA de contenido no estructurado.
- Diferencial: correlacion suenos con contexto diario (estres, actividad, alimentacion).
- Resultado esperado: autoconocimiento accionable y gestion emocional con evidencia.

## Objetivo general
- App movil multiplataforma para registrar suenos en formato multimedia y obtener analisis emocional cualitativo/cuantitativo con IA.

## Funciones clave
- Auth y nube: registro/login/perfil + persistencia segura.
- Diario CRUD: entrada por texto y/o audio, guardado de audio, vista cronologica.
- IA opcional: transcripcion, sentimiento, entidades (emociones/personajes/lugares) e interpretacion psicologica opcional.
- Dashboard: evolucion emocional, elementos recurrentes y patrones temporales.
- Privacidad: switch para activar/desactivar IA + biometria.

## Stack tecnico
- Framework: Flutter (Dart)
- Backend: Firebase (Auth, Firestore, Storage, Functions)
- IA: Google Gemini API
- Librerias clave: speech_to_text, fl_chart, local_auth
- Plataformas: Android, iOS, Web, Windows, macOS, Linux

## Arquitectura y convenciones
- Enfoque de cambios: minimo cambio necesario, orientado a causa raiz.
- Prioridad tecnica: estabilidad de integracion Flutter + Firebase.
- Validacion: ejecutar la comprobacion mas acotada y significativa por cambio.

## Estado de agentes
- Agente tecnico principal: Infra Mobile Firebase AI
- Agente de personalizacion: Gestor de Agentes Copilot
- Agente intermediario de decisiones: Software Decision Orchestrator

## Estructura de agentes para desarrollo
- Software Decision Orchestrator: responsable de intermediacion usuario-agentes, priorizacion tecnica y decisiones de alcance.
- Flutter UX App Agent: responsable de UI/UX, componentes, navegacion y accesibilidad.
- Firebase Backend Security Agent: responsable de Auth, reglas, Functions y seguridad backend.
- QA Release Agent: responsable de validacion transversal y readiness de release.
- Data Insights Agent: responsable de metrica, eventos e insights de patrones.

## Documentos operativos de agentes
- Coordinacion global: .github/agents/contexts/shared/shared-agent-coordination.md
- Contexto de estilos UX: .github/agents/contexts/specialized/flutter-ux-style-context.md
- Runbook backend Firebase: .github/docs/guides/firebase-backend-runbook.md
- Checklist QA/Release: .github/docs/checklists/qa-release-checklist.md
- Contexto de metricas/insights: .github/agents/contexts/specialized/data-insights-metric-context.md

## Versionado y ramas
- Convencion: feat/mvp-vX → merge a main → tag semantico vX.Y.Z → release APK
- MAJOR: rediseno o ruptura de compatibilidad | MINOR: sprint/feature completa | PATCH: bug fix
- La version en pubspec.yaml se actualiza en la rama antes del merge.
- El tag se crea sobre el commit de merge en main.
- Historial completo: CHANGELOG.md

### Versiones activas
- v1.0.0 (main, tag v1.0.0): MVP completo — auth, CRUD, audio, IA Gemini, dashboard
- v1.1.0+2 (feat/mvp-v2): en desarrollo — cambios pendientes de definir

## Distribucion de APK
- Plataforma primaria: Firebase App Distribution (ya integrado en el stack)
- Alternativa secundaria: GitHub Releases (APK adjunta al tag de version)

## Ultima actualizacion
- Fecha: 2026-05-16
- Nota: Sistema de versionado semantico vinculado a ramas establecido. Tag v1.0.0 publicado.
