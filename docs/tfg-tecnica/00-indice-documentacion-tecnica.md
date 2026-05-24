# Paquete de Documentacion Tecnica TFG

Estado: Borrador inicial
Idioma: Espanol
Estilo de redaccion: Tecnico entendible (nivel 6-7)

## Objetivo
Este paquete contiene la documentacion tecnica separada de la memoria principal.
La memoria sintetiza decisiones y resultados, mientras que estos documentos guardan el detalle verificable.

## Estructura del paquete
1. [01-arquitectura-tecnica-e2e.md](01-arquitectura-tecnica-e2e.md)
2. [02-backend-firebase-control-acceso.md](02-backend-firebase-control-acceso.md)
3. [03-cloud-functions-ia.md](03-cloud-functions-ia.md)
4. [04-qa-trazabilidad-resultados.md](04-qa-trazabilidad-resultados.md)
5. [05-operacion-despliegue-rollback.md](05-operacion-despliegue-rollback.md)
6. [06-riesgos-tecnicos-mitigacion.md](06-riesgos-tecnicos-mitigacion.md)
7. [07-compliance-privacidad-consentimiento.md](07-compliance-privacidad-consentimiento.md)
8. [A01-anexo-evidencias-tecnicas.md](A01-anexo-evidencias-tecnicas.md)
9. [A02-matriz-trazabilidad-requisito-prueba.md](A02-matriz-trazabilidad-requisito-prueba.md)

## Criterios de calidad del paquete
- Coherencia con el codigo y configuracion actual del repositorio.
- Trazabilidad de afirmaciones: cada apartado tecnico debe apuntar a evidencia.
- Terminologia consistente entre memoria, anexos y artefactos de proyecto.
- No duplicar contenido narrativo de la memoria principal.

## Fuentes base del repositorio
- [firestore.rules](../../firestore.rules)
- [storage.rules](../../storage.rules)
- [functions/src/index.ts](../../functions/src/index.ts)
- [QA_TEST_PLAN.md](../../QA_TEST_PLAN.md)
- [CHANGELOG.md](../../CHANGELOG.md)
- [.github/docs/guides/firebase-backend-runbook.md](../../.github/docs/guides/firebase-backend-runbook.md)
- [.github/agents/contexts/shared/shared-lifecycle-history.md](../../.github/agents/contexts/shared/shared-lifecycle-history.md)

## Nota de uso
- Este paquete no sustituye a la memoria principal.
- Se recomienda citar estos documentos en el apartado de anexos de la memoria.
