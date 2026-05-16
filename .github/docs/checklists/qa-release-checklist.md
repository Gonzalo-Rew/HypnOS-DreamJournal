# QA Release Checklist

Checklist de calidad previa a merge o release.

## Smoke funcional
- Login y logout.
- Crear, editar y borrar entrada de diario.
- Subir y reproducir audio.
- Cargar dashboard basico.

## Integracion
- Inicializacion Firebase correcta por plataforma objetivo.
- Permisos de microfono/biometria correctamente manejados.
- Errores de red con feedback claro.

## Calidad tecnica
- Sin errores de analisis.
- Pruebas unitarias/widget relevantes ejecutadas.
- No regressions evidentes en rutas criticas.

## Release readiness
- Versionado y build metadata correctos.
- Riesgos conocidos documentados.
- Plan de rollback o mitigacion definido.
