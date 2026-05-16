# Fase 1 - Analisis y Diseno (Entregable de Sprint 1)

Estado: En ejecucion

## Objetivo
Alinear producto, UX y base tecnica para comenzar Fase 2 con bajo riesgo de retrabajo.

## 1) Definicion de prototipos (Figma)

## Alcance del prototipo
- Flujo de onboarding y autenticacion (registro/login).
- Pantalla de Home con acceso rapido a nueva entrada.
- Flujo de nueva entrada de sueno (texto en Fase 2, audio visible como proxima capacidad).
- Lista cronologica de suenos.
- Detalle de sueno.
- Perfil y ajustes (incluye switch IA futuro).

## Estructura de wireflow propuesta
1. Splash -> Auth Gate
2. Login/Registro -> Home
3. Home -> Nueva entrada
4. Home -> Lista de suenos -> Detalle
5. Home -> Perfil/Ajustes

## Criterios de aceptacion UX del prototipo
- Captura textual posible en menos de 60 segundos.
- Navegacion principal en maximo 2 toques desde Home.
- Jerarquia visual clara para acciones primarias.
- Estados vacios definidos para lista sin registros.

## 2) Esquema inicial de base de datos

## Firestore (colecciones)

### users/{uid}
- displayName: string
- email: string
- createdAt: timestamp
- aiEnabled: bool
- timezone: string
- photoUrl: string | null
- notificationsEnabled: bool
- notificationTime: string (HH:mm, por defecto "08:00")

### users/{uid}/dreams/{dreamId}
- title: string
- text: string
- dreamDate: timestamp
- createdAt: timestamp
- updatedAt: timestamp
- moodScore: number | null (escala 1-5)
- tags: array<string>
- contextNotes: string | null (notas de contexto del dia: estres, actividad, etc.)
- aiCategory: string | null (asignada por IA: pesadilla, lucido, recurrente, etc.)
- hasAudio: bool
- audioPath: string | null
- transcription: string | null
- aiSummary: string | null

### users/{uid}/insights/{insightId}
- periodStart: timestamp
- periodEnd: timestamp
- dominantEmotions: array<string>
- recurringTags: array<string>
- generatedAt: timestamp

## Cloud Storage
- Ruta de audio: users/{uid}/dreams/{dreamId}/audio.m4a

## Reglas iniciales de modelado
- Todo documento de sueno pertenece al uid autenticado.
- Timestamps en UTC para analisis consistente.
- Campos IA opcionales y nulos por defecto hasta Fase 3.

## 3) Arquitectura de referencia

## Capas
- Presentation: pantallas, widgets y estado UI.
- Application: casos de uso (crear sueno, listar suenos, autenticar).
- Data: repositorios e implementaciones Firebase.
- Core: utilidades compartidas, errores tipados y config.

## Modulos iniciales en lib/
- app/ (router, theme, bootstrap)
- features/auth/
- features/dreams/
- features/profile/
- shared/

## Integraciones
- Firebase Auth para identidad.
- Firestore para diario y metadatos.
- Storage para audio (Fase 3 activacion).
- Cloud Functions opcional para procesos IA.

## Decisiones tecnicas iniciales
- Enfoque mobile-first con soporte multiplataforma progresivo.
- Repository pattern para desacoplar UI de Firebase.
- Feature flags para capacidades IA en rollout gradual.

## Riesgos y mitigacion (Sprint 1)
- Riesgo: cambios de UX tardios impactan modelo de datos.
  Mitigacion: congelar entidades nucleares al 70 porciento del sprint.
- Riesgo: sobre-diseno de arquitectura retrasa Fase 2.
  Mitigacion: limitarse a arquitectura minima viable con extension controlada.
- Riesgo: reglas de seguridad no definidas a tiempo.
  Mitigacion: preparar borrador de reglas al cierre de Fase 1.

## Cierre esperado de Sprint 1
Para considerar Sprint 1 como aprobado:
1. Prototipo y flujo principal validados por Product Owner.
2. Esquema de datos aceptado para desarrollo.
3. Blueprint de arquitectura aprobado para implementacion del core.
4. Backlog tecnico de Sprint 2 derivado y priorizado.
