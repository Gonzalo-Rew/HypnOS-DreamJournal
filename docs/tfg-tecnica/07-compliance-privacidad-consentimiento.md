# Documento 07 - Compliance, Privacidad y Consentimiento

Estado: Borrador
Responsable: Firebase Backend Security Agent

## 1. Objetivo
Evidenciar cumplimiento técnico de privacidad, consentimiento y gobernanza del dato.

## 2. Datos tratados
- Tipos de datos personales.
- Finalidad de tratamiento.
- Minimización.

## 3. Consentimiento y trazabilidad
- Flujo de aceptación.
- Versionado de términos/política.
- Evidencia de consentimiento.

## 4. Control de acceso y protección de datos
- Reglas de acceso por usuario.
- Exposición en funcionalidades sociales.

## 5. Derecho de supresión y borrado de cuenta
- Flujo técnico de borrado.
- Alcance del borrado.
- Limitaciones declaradas.

## 6. Riesgos de compliance y mitigación
- Riesgo de consentimientos incompletos.
- Riesgo de retención indebida.
- Riesgo de acceso no autorizado.

## 7. Evidencias base
- [firestore.rules](../../firestore.rules)
- [storage.rules](../../storage.rules)
- [functions/src/index.ts](../../functions/src/index.ts)
- [shared-lifecycle-history.md](../../.github/agents/contexts/shared/shared-lifecycle-history.md)
