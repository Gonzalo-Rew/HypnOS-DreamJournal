# Sprint Development Plan

Este documento define como se planifica, ejecuta y valida cada sprint de Hypnos Dream Journal.
El objetivo es asegurar una entrega incremental al final de cada sprint: un producto potencialmente utilizable para validacion con Product Owner (tu).

## Objetivo del proceso
- Entregar incrementos funcionales al cierre de cada sprint.
- Reducir riesgo tecnico y de producto mediante validacion frecuente.
- Ajustar alcance con feedback real antes de avanzar a la siguiente fase.

## Cadencia de trabajo (proceso habitual)
- Inicio de sprint: planificacion de objetivos, historias y criterios de aceptacion.
- Durante el sprint: desarrollo incremental + pruebas continuas.
- Cierre de sprint: demo funcional, validacion contigo y decision Go/No-Go.
- Post-cierre: retrospectiva corta y ajustes de backlog.

## Criterios de salida por sprint
- Incremento ejecutable y verificable en entorno de desarrollo.
- Historias comprometidas completadas con criterios de aceptacion.
- Riesgos y deuda tecnica documentados.
- Decision de validacion del Product Owner registrada.

## Fases del roadmap

### Fase 1: Analisis y Diseno
Objetivo: definir base funcional y tecnica antes de construir.

Entregables esperados:
- Prototipos clave en Figma (flujo principal de captura y consulta).
- Esquema de base de datos inicial (Firestore y Storage).
- Arquitectura de la app (capas, modulos, flujo de datos y servicios).

Criterio de aceptacion de fase:
- Prototipo aprobado.
- Modelo de datos validado.
- Arquitectura acordada para iniciar desarrollo del core.

### Fase 2: Desarrollo del Core
Objetivo: construir el MVP funcional con persistencia en Firebase.

Entregables esperados:
- Autenticacion (registro, login, logout, estado de sesion).
- CRUD de suenos en texto.
- Integracion base con Firebase (Auth + Firestore + reglas iniciales).

Criterio de aceptacion de fase:
- Usuario puede autenticarse y gestionar su diario textual de extremo a extremo.
- Datos persisten en nube de forma consistente.

### Fase 3: Multimedia e IA
Objetivo: enriquecer el registro con audio e inteligencia artificial.

Entregables esperados:
- Grabacion y almacenamiento de audio de suenos.
- Transcripcion de audio a texto.
- Integracion con Gemini API para analisis inicial.

Criterio de aceptacion de fase:
- Flujo audio -> transcripcion -> analisis funciona con estabilidad en entorno de pruebas.

### Fase 4: Analisis de Datos y UI
Objetivo: convertir datos en insights y pulir experiencia de uso.

Entregables esperados:
- Dashboard de estadisticas y patrones.
- Visualizaciones de evolucion temporal.
- Pulido de interfaz y consistencia UX.

Criterio de aceptacion de fase:
- Dashboard usable y coherente con decisiones de producto.
- UI final estable y lista para validacion de cierre.

## Plantilla de registro por sprint

## Sprint [ID]
- Fase: [1|2|3|4]
- Objetivo del sprint:
- Alcance comprometido:
- Entregable potencialmente utilizable:
- Criterios de aceptacion:
- Resultado de demo:
- Feedback del Product Owner:
- Decisiones tomadas:
- Riesgos detectados:
- Plan de mitigacion:
- Estado final: [Aprobado | Aprobado con ajustes | Rechazado]
- Acciones para siguiente sprint:

## Sprint 1
- Fase: 1 (Analisis y Diseno)
- Objetivo del sprint:
	Definir y validar la base de producto y tecnica para iniciar el desarrollo del core sin ambiguedades.
- Alcance comprometido:
	1) Prototipo navegable en Figma de flujo principal.
	2) Esquema inicial de datos para Firestore y Storage.
	3) Arquitectura Flutter + Firebase de referencia.
- Entregable potencialmente utilizable:
	Documento de Fase 1 con decisiones de diseno, modelo de datos y blueprint de arquitectura listo para implementar en Fase 2.
- Criterios de aceptacion:
	1) Flujo UX principal definido (captura, lista, detalle, perfil).
	2) Colecciones y campos principales aprobados.
	3) Capas tecnicas y responsabilidades acordadas.
	4) Riesgos iniciales identificados con mitigacion.
- Resultado de demo:
	En curso.
- Feedback del Product Owner:
	Pendiente.
- Decisiones tomadas:
	Se inicia con priorizacion de rapidez de captura y trazabilidad emocional.
- Riesgos detectados:
	Dependencia de definicion UX para evitar retrabajo en Fase 2.
- Plan de mitigacion:
	Revisiones intermedias de wireflow y modelo de datos para evitar retrabajo.
- Estado final: En curso
- Acciones para siguiente sprint:
	Preparar backlog tecnico de Fase 2 basado en decisiones aprobadas de Fase 1.

## Sprint 2
- Fase: 2 (Desarrollo del Core)
- Objetivo del sprint:
	Construir MVP funcional de autenticacion, CRUD de suenos y persistencia Firebase end-to-end.
- Alcance comprometido:
	1) Autenticacion: registro, login, logout, estado de sesion persistente.
	2) CRUD de suenos: crear, listar, ver detalle, editar, eliminar.
	3) Integracion Firebase: Auth + Firestore + reglas de seguridad iniciales.
	4) Estructura del proyecto Flutter lista para Fase 3.
- Entregable potencialmente utilizable:
	App Flutter compilable con flujo completo de autenticacion y gestion de diario textual. Datos sincronizados con Firestore.
- Criterios de aceptacion:
	1) Usuario puede registrarse, loguear y mantener sesion activa.
	2) Usuario puede crear, leer, editar y eliminar sueños.
	3) Datos persisten en Firestore de forma consistente.
	4) Reglas de seguridad evitan acceso no autorizado.
	5) App compila para Android, iOS y Web sin errores.
- Tareas principales:
	Firebase Backend Security Agent:
	- Configurar Firebase Auth (email/password).
	- Crear colecciones en Firestore (users, dreams).
	- Escribir y validar reglas de seguridad.
	- Documentar estructura de datos en readme.
	Flutter UX App Agent:
	- Setup GoRouter y navegacion.
	- Pantalla de Login y Registro.
	- Pantalla Home con acceso a nueva entrada.
	- Formulario Nueva Entrada (texto + fecha + mood).
	- Lista cronologica de suenos.
	- Detalle y edicion de sueno.
	- Pantalla Perfil.
	Infra Mobile Firebase AI:
	- Instalar y configurar dependencias en pubspec.yaml.
	- Setup de configuracion por entorno (dev/prod).
	- Configurar GitHub Actions para builds automaticos.
	- Validar compilacion en Android, iOS, Web.
- Resultado de demo:
	Pendiente.
- Feedback del Product Owner:
	Pendiente.
- Decisiones tomadas:
	Priorizacion de rapidez de captura, seguridad de datos y compilacion multiplataforma.
- Riesgos detectados:
	1) Retrabajo de Firebase si esquema de datos cambia en Fase 1.
	2) Bloqueo de Flutter si Auth no esta lista.
	3) Build inestables en CI/CD por dependencias no resueltas.
- Plan de mitigacion:
	1) Congelar esquema de datos antes de iniciar Sprint 2.
	2) Firebase Backend comienza primero, Flutter UX trabaja con mocks en paralelo.
	3) Validar CI/CD continuo, no al final del sprint.
- Estado final: Planificado
- Acciones para siguiente sprint:
	Preparar backlog tecnico de Fase 3 basado en estabilidad de Core en Sprint 2.

 ## Bitacora de sprints
- Sprint 1 (Fase 1) en ejecucion.
- Sprint 2 (Fase 2) en planificacion.
- El feedback del Product Owner define prioridad del siguiente sprint.
- No se avanza de fase sin acuerdo explicito sobre el incremento entregado.
