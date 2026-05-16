# Estructura de Agentes (.github/agents)

## Objetivo
Mantener separada la configuracion de agentes, sus contextos compartidos y la documentacion de apoyo.

## Estructura recomendada
- `*.agent.md`: definiciones de agentes (se mantienen en esta carpeta para descubrimiento directo).
- `contexts/shared/`: contexto comun obligatorio para todos los agentes.
- `contexts/specialized/`: contextos especializados por dominio.

## Contextos compartidos obligatorios
- `.github/agents/contexts/shared/shared-app-context.md`
- `.github/agents/contexts/shared/shared-lifecycle-history.md`
- `.github/agents/contexts/shared/shared-agent-coordination.md`

## Documentacion externa separada
- Guias: `.github/docs/guides/`
- Checklists: `.github/docs/checklists/`
- Planes: `.github/docs/plans/`
- Estado: `.github/docs/status/`
- Reportes: `.github/docs/reports/`

## Regla para agentes futuros
Cualquier nuevo `.agent.md` debe referenciar explicitamente los 3 contextos compartidos en su seccion de archivos obligatorios.
