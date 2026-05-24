# Documento 05 - Operación, Despliegue y Rollback

Estado: Borrador
Responsable: Infra Mobile Firebase AI

## 1. Objetivo
Estandarizar el proceso operativo de despliegue y recuperación ante incidencias.

## 2. Entornos
- Desarrollo: validación local de funcionalidades y corrección rápida.
- Pruebas: verificación pre-release con datos controlados y checklist QA.
- Producción: versión publicada para usuarios finales en tiendas oficiales.

## 3. Proceso de despliegue
### 3.1 Pre-despliegue
- Congelar rama/release candidata.
- Ejecutar validación funcional en rutas críticas.
- Verificar consistencia de configuración Firebase y secretos.
- Revisar versionado de app y changelog.

### 3.2 Despliegue de reglas
- Desplegar reglas de Firestore y Storage.
- Confirmar sintaxis y despliegue sin errores.
- Validar al menos un caso permitido y uno denegado tras el despliegue.

### 3.3 Despliegue de functions
- Compilar proyecto de Functions.
- Desplegar funciones cloud de forma controlada.
- Verificar salud de endpoints y triggers críticos.

### 3.4 Verificaciones post-despliegue
- Probar login, CRUD de sueños, análisis IA y notificaciones en entorno objetivo.
- Revisar logs de errores en Firebase Functions.
- Confirmar ausencia de regresiones críticas detectadas en checklist de release.

## 4. Rollback
### 4.1 Escenarios de activación
1. Caída del flujo de autenticación.
2. Fallo generalizado en análisis IA.
3. Errores de permisos por reglas en producción.
4. Incidencias graves de estabilidad tras release.

### 4.2 Procedimiento
1. Identificar versión estable anterior.
2. Revertir reglas/functions afectadas según alcance del fallo.
3. Publicar hotfix o rollback completo según severidad.
4. Ejecutar smoke test mínimo tras rollback.

### 4.3 Verificación posterior
1. Confirmar restauración del flujo crítico.
2. Registrar incidencia y causa raíz.
3. Definir acción preventiva para siguiente release.

## 5. Monitorización operativa
### 5.1 Señales mínimas a monitorizar
1. Errores de login/auth.
2. Errores de permisos Firestore/Storage.
3. Tasa de error de analyzeDream.
4. Latencia media y p95 de funciones críticas.

### 5.2 Umbrales operativos recomendados
1. Error rate de función crítica > 5 por ciento en ventana corta: abrir incidente.
2. Latencia p95 anómala frente a baseline: activar revisión técnica.
3. Aumento de errores de permisos tras deploy: bloquear avance y analizar reglas.

## 6. Plan de publicación en tiendas
### 6.1 Google Play
1. Alta de cuenta de desarrollador.
2. Publicación inicial en canal de prueba cerrada.
3. Validación de crash rate y feedback de beta.
4. Apertura a producción gradual.

### 6.2 Apple App Store
1. Alta en Apple Developer Program.
2. Preparación de metadatos, privacidad y capturas.
3. Envío a revisión y resolución de observaciones.
4. Publicación progresiva.

## 7. Presupuesto base de despliegue y operación
### 7.1 Costes fijos iniciales
1. Google Play Console: pago único (referencia habitual: 25 USD).
2. Apple Developer Program: pago anual (referencia habitual: 99 USD/año).

### 7.2 Costes variables mensuales
1. Firebase (según uso de Firestore, Storage y Functions).
2. Inferencia IA por consumo del modelo.
3. Herramientas de productividad/licencias técnicas.

### 7.3 Modelo de ingresos
Se propone modelo freemium con suscripción para análisis IA avanzado.

Escenario base de diseño económico:
1. Capa gratuita: uso limitado del análisis IA.
2. Capa de pago: mayor capacidad mensual y funcionalidades premium.

## 8. Plantilla de estimación económica por escenarios
Usar tres escenarios para memoria técnica y defensa:
1. Conservador.
2. Realista.
3. Optimista.

Campos mínimos por escenario:
1. Usuarios activos/mes.
2. Análisis IA por usuario/mes.
3. Coste IA mensual estimado.
4. Coste total operativo mensual.
5. Ingresos por suscripción.
6. Margen estimado.

## 9. Evidencias base
- [firebase-backend-runbook.md](../../.github/docs/guides/firebase-backend-runbook.md)
- [PHASE2-SUMMARY.md](../../.github/firebase/PHASE2-SUMMARY.md)
- [QUICK-START-DEPLOY.md](../../.github/firebase/QUICK-START-DEPLOY.md)
- [CHANGELOG.md](../../CHANGELOG.md)
