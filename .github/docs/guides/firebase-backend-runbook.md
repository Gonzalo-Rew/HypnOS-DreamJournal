# Firebase Backend Runbook

Checklist operativo para backend y seguridad Firebase.

## Ambito
- Firebase Auth
- Firestore
- Cloud Storage
- Cloud Functions
- Entornos y despliegues

## Guardrails
- Denegar por defecto en reglas, abrir por necesidad.
- Validar ownership de datos por uid.
- Evitar acceso publico a Storage sin reglas estrictas.

## Flujo de cambios
1. Definir requerimiento de datos y acceso.
2. Ajustar reglas minimas necesarias.
3. Probar casos permitidos y denegados.
4. Desplegar con verificacion posterior.

## Evidencias minimas
- Archivo de reglas actualizado.
- Comando de despliegue ejecutado o plan de despliegue.
- Resultado de validacion de acceso.
