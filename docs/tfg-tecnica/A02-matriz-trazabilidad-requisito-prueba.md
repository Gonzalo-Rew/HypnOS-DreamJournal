# Anexo A02 - Matriz de Trazabilidad Requisito-Prueba

Estado: Borrador

## 1. Objetivo
Garantizar trazabilidad completa entre requisitos, implementación, pruebas y evidencia.

## 2. Estructura de matriz
| Req ID | Requisito | Componente/Archivo | Prueba (ID) | Evidencia | Estado |
|---|---|---|---|---|---|
| RQ-001 | Registro/login | lib/features/auth | F01, F02 | EV-010 | Pendiente |
| RQ-002 | CRUD suenos | lib/features/dreams | F03, F04, F05 | EV-020 | Pendiente |
| RQ-003 | Seguridad acceso | firestore.rules | Security T-01..T-N | EV-030 | Pendiente |

## 3. Criterios de completitud
- Todo requisito crítico debe tener al menos una prueba ejecutada.
- Todo resultado debe tener evidencia asociada.
- No cerrar documento con filas sin estado.

## 4. Fuentes base
- [QA_TEST_PLAN.md](../../QA_TEST_PLAN.md)
- [FEATURE_IMPLEMENTATION_GUIDE.md](../../FEATURE_IMPLEMENTATION_GUIDE.md)
- [CHANGELOG.md](../../CHANGELOG.md)
- [A01-anexo-evidencias-tecnicas.md](A01-anexo-evidencias-tecnicas.md)