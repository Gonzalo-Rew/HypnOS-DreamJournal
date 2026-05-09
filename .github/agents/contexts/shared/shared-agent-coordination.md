# Shared Agent Coordination

Este documento define como se coordinan los agentes del proyecto para evitar solapamientos y mejorar velocidad de entrega.

## Reglas globales
- Todos los agentes leen primero .github/agents/contexts/shared/shared-app-context.md.
- Todo cambio significativo se registra en .github/agents/contexts/shared/shared-lifecycle-history.md.
- Si una tarea cruza dominios, el agente principal delega al agente especialista.
- Cada agente responde solo dentro de su dominio y evita cambios laterales.

## Flujo de handoff
1. Agente principal identifica limite tecnico de la tarea.
2. Si necesita especialidad adicional, delega con contexto minimo:
   - objetivo
   - restriccion
   - archivos implicados
   - criterio de validacion
3. Agente especialista devuelve resultado accionable y riesgos.
4. Agente principal integra, valida y cierra.

## Mapa de especialidades
- Software Decision Orchestrator: intermediacion con el usuario, toma de decisiones tecnicas y coordinacion de handoffs entre especialistas.
- Infra Mobile Firebase AI: integracion end-to-end, entorno, CI/CD, Firebase/GCP, IA.
- Flutter UX App Agent: UI Flutter, navegacion, componentes, estados de pantalla y accesibilidad.
- Firebase Backend Security Agent: Auth, Firestore/Storage rules, Functions, seguridad y despliegue backend.
- QA Release Agent: pruebas, regresion, hardening pre-release, checklist de entrega.
- Data Insights Agent: eventos, metrica de producto, modelos de analitica y dashboards.

## Criterios para delegar
- Priorizacion tecnica, decisiones de alcance y coordinacion multi-dominio: delegar a Software Decision Orchestrator.
- UI/UX y arquitectura de interfaz: delegar a Flutter UX App Agent.
- Seguridad de datos o reglas de acceso: delegar a Firebase Backend Security Agent.
- Preparacion de release o validacion transversal: delegar a QA Release Agent.
- Definicion de metricas o analitica de patrones: delegar a Data Insights Agent.
