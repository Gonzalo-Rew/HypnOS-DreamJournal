# Shared Lifecycle History

Este archivo guarda un historial generico del proceso de vida de la aplicacion.
El objetivo es facilitar la redaccion futura del documento TFG con trazabilidad tecnica.

## Reglas de uso
- Aplica a todos los agentes actuales y futuros del proyecto.
- Registrar hitos relevantes despues de cambios significativos.
- Usar un formato breve, cronologico y verificable.
- No incluir secretos, credenciales ni datos sensibles.

## Formato de registro
- Fecha: YYYY-MM-DD
- Categoria: Arquitectura | Firebase | Auth | Firestore | Storage | Functions | CI/CD | Release | QA | Agentes
- Cambio: descripcion concreta de lo realizado
- Impacto: que mejora, corrige o habilita
- Evidencia: archivo(s), comando(s) o validacion asociada

## Historial

- Fecha: 2026-05-24
- Categoria: Documentacion | TFG | Agentes
- Cambio: Se unifica la documentacion en un unico documento fuente (`docs/memoria-principal-borrador.md`) integrando dentro de la propia memoria el detalle tecnico de codigo, el anexo de evidencias y la matriz de trazabilidad. Se eliminan archivos markdown auxiliares en `docs/tfg-tecnica` y `docs/anteproyecto.txt`.
- Impacto: Estructura de entrega simplificada y alineada con criterio memoria-principal como unico artefacto textual evaluable.
- Evidencia: docs/memoria-principal-borrador.md, docs/tfg-tecnica (limpieza de markdown), .github/agents/contexts/shared/shared-lifecycle-history.md.

- Fecha: 2026-05-24
- Categoria: Documentacion | TFG | Agentes
- Cambio: Refactor documental a estrategia memoria-principal. Se consolida la documentacion tecnica en un unico archivo de soporte de codigo y se eliminan los markdown fragmentados por dominio (01..07). Se actualizan referencias de memoria y anexos para trazabilidad con EV hacia el nuevo documento unificado.
- Impacto: Reduce dispersion documental, mejora legibilidad para evaluacion DAM y deja fuera de memoria solo detalle implementativo no narrativo.
- Evidencia: docs/memoria-principal-borrador.md, docs/tfg-tecnica/documentacion-tecnica-codigo.md, docs/tfg-tecnica/00-indice-documentacion-tecnica.md, docs/tfg-tecnica/A01-anexo-evidencias-tecnicas.md.

- Fecha: 2026-05-24
- Categoria: QA | Release | Documentacion
- Cambio: Se incorpora en la memoria principal un cierre de calidad orientado a tribunal DAM con estructura de resultados, KPIs de release, tabla de metricas en estado de consolidacion, criterios Go/No-Go por plataforma (Android/iOS) y plan de mitigacion de riesgos residuales.
- Impacto: Mejora la trazabilidad de readiness de release y deja un marco formal para decision de salida sin cerrar resultados sin evidencia consolidada.
- Evidencia: docs/memoria-principal-borrador.md (seccion 9.1), .github/docs/checklists/qa-release-checklist.md.

- Fecha: 2026-05-24
- Categoria: Agentes | Documentacion | TFG
- Cambio: Se crea el agente `Project Memory Documentation Agent` y su contexto especializado para elaborar memoria y manuales del TFG con enfoque tecnico, coordinacion multiagente y politica de referencias IEEE.
- Impacto: Queda habilitado un flujo dedicado para redaccion evaluable con trazabilidad de evidencia del proyecto y soporte de validacion cruzada con agentes especialistas.
- Evidencia: .github/agents/project-memory-documentation.agent.md, .github/agents/contexts/specialized/project-memory-context.md, .github/agents/contexts/shared/shared-app-context.md, .github/agents/contexts/shared/shared-agent-coordination.md.

- Fecha: 2026-05-24
- Categoria: Notifications | UX | Bugfix
- Cambio: Se aplica parche minimo en el scheduler local de recordatorio diario para usuarios legacy: en `NotificationService` se alinea el fallback de `notificationsEnabled` a `true` (antes `false`) cuando el campo no existe en `users/{uid}`.
- Impacto: Evita que el recordatorio diario quede desactivado silenciosamente en perfiles sin `notificationsEnabled` persistido, alineando comportamiento con `User.fromFirestore` y la UI.
- Evidencia: lib/data/services/notification_service.dart, `flutter analyze lib/data/services/notification_service.dart` (No issues found).

- Fecha: 2026-05-24
- Categoria: Notifications | Android | Timezone
- Cambio: Se endurece la inicializacion de recordatorios locales: `NotificationService` ahora registra error y hace fallback explicito de timezone a `UTC` si falla `FlutterTimezone`, y solicita permiso de notificaciones locales en Android mediante `requestNotificationsPermission()`.
- Impacto: Reduce casos en los que el recordatorio diario no se dispara por fallo de resolucion de zona horaria o por permiso local no concedido en Android 13+.
- Evidencia: lib/data/services/notification_service.dart, `flutter analyze lib/data/services/notification_service.dart` (No issues found).

- Fecha: 2026-05-24
- Categoria: Notifications | Debug
- Cambio: Se instrumenta trazabilidad de recordatorios diarios con logs en puntos criticos (`Init`, `Start`, `Snapshot`, `Apply`, `Schedule`, `Cancel`) y verificacion de `pendingNotificationRequests` tras programar.
- Impacto: Permite diagnosticar rapidamente si el problema esta en lectura de ajustes de Firestore, parseo de hora, timezone local o programacion efectiva de la notificacion local.
- Evidencia: lib/data/services/notification_service.dart, `flutter analyze lib/data/services/notification_service.dart` (No issues found).

- Fecha: 2026-05-24
- Categoria: Firebase | Auth | Profile | Storage
- Cambio: Se corrige el `PERMISSION_DENIED` al quitar la foto de perfil. El cliente deja de persistir `photoUrl: null` y pasa a borrar el campo con `FieldValue.delete()`, además de rehidratar `displayName` si faltaba en documentos legacy; en Firestore Rules se explicita que `photoUrl` puede ser `null` o `string` en updates del owner.
- Impacto: El usuario propietario ya puede eliminar su avatar sin bloqueo por permisos y los perfiles antiguos con `displayName` mal persistido dejan de romper updates simples de perfil.
- Evidencia: lib/data/repositories/auth_repository.dart, firestore.rules, `flutter analyze lib/data/repositories/auth_repository.dart lib/features/settings/presentation/edit_profile_screen.dart lib/data/models/user_model.dart` (sin errores nuevos; 1 info deprecado preexistente), `firebase deploy --only firestore:rules --project hypnos-dream-journal` (EXIT 0).

- Fecha: 2026-05-24
- Categoria: Compliance | Legal | Deploy
- Cambio: Se ajustan Terminos y Politica para explicitar que crear cuenta requiere aceptar expresamente ambos documentos y para transparentar que, en funciones sociales, cierta metadata de interaccion puede ser visible entre usuarios autenticados. Se completa despliegue de reglas y funciones en Firebase.
- Impacto: Los 4 puntos de seguridad/compliance acordados quedan aplicados y activos en entorno Firebase del proyecto.
- Evidencia: lib/features/settings/presentation/legal_screen.dart, firebase deploy --only firestore:rules,storage,functions --project hypnos-dream-journal, firebase functions:list --project hypnos-dream-journal.

- Fecha: 2026-05-24
- Categoria: UX | Profile | Auth | Storage
- Cambio: Se añade la opción de quitar la foto de perfil desde editar perfil. La pantalla expone acción explícita `Quitar avatar`, el repositorio de auth soporta limpieza intencional de `photoUrl` (`clearPhotoUrl`) y el borrado del archivo de Storage se hace en best-effort tolerando `object-not-found`.
- Impacto: El usuario ya puede volver al avatar por iniciales después de haber subido una imagen, sin quedar bloqueado en un estado con foto permanente.
- Evidencia: lib/features/settings/presentation/edit_profile_screen.dart, lib/data/repositories/auth_repository.dart, lib/data/models/user_model.dart, lib/l10n/app_es.arb, lib/l10n/app_en.arb, `flutter analyze lib/features/settings/presentation/edit_profile_screen.dart lib/data/repositories/auth_repository.dart lib/data/models/user_model.dart` (sin errores nuevos; 1 info preexistente deprecado en auth_repository.dart).


- Fecha: 2026-05-24
- Categoria: Compliance | Auth | Functions | Legal
- Cambio: Se refuerza cumplimiento de privacidad con dos medidas: (1) consentimiento legal explicito en registro (checkbox obligatorio) y persistencia versionada de aceptacion (`termsAcceptedAt`, `privacyAcceptedAt`, `termsVersion`, `privacyVersion`) en `users/{uid}`; (2) limpieza integral de datos al eliminar cuenta mediante trigger de Auth (`cleanupUserDataOnAuthDelete`) que elimina datos Firestore relacionados y archivos de Storage bajo `users/{uid}/`. Ademas se actualiza el texto legal para eliminar claims no implementados (exportacion in-app y bloqueo de seguidores).
- Impacto: Mejora trazabilidad de consentimiento, reduce riesgo de datos huerfanos tras baja de cuenta y alinea politicas/terminos con capacidades reales de la app.
- Evidencia: lib/features/auth/presentation/register_screen.dart, lib/data/repositories/auth_repository.dart, lib/data/models/user_model.dart, lib/core/constants/app_constants.dart, firestore.rules, functions/src/index.ts, lib/features/settings/presentation/legal_screen.dart.

- Fecha: 2026-05-24
- Categoria: UX | IA | Dreams
- Cambio: Se habilita analisis de suenos solo-audio en detalle. `DreamDetailScreen` ahora usa `transcription` si `text` esta vacio y, si no existe transcripcion guardada, intenta transcribir audios remotos (`audioPaths`) antes de llamar a Morfeo.
- Impacto: Los suenos ya creados con solo audio pueden analizarse desde detalle usando transcripcion, evitando error por texto vacio.
- Evidencia: lib/features/dreams/presentation/dream_detail_screen.dart, `flutter analyze lib/features/dreams/presentation/dream_detail_screen.dart lib/features/dreams/presentation/dream_analysis_step_screen.dart` (No issues found).

- Fecha: 2026-05-23
- Categoria: Auth | UX | Android
- Cambio: Se elimina la opción visible de "Continuar con Apple" en las pantallas de inicio de sesión y registro para evitar intentos de autenticación Apple no soportados/configurados en el flujo actual.
- Impacto: El usuario ya no puede disparar el flujo de Apple Sign-In desde UI; se reduce fricción y errores en login.
- Evidencia: lib/features/auth/presentation/login_screen.dart, lib/features/auth/presentation/register_screen.dart, `flutter analyze lib/features/auth/presentation/login_screen.dart lib/features/auth/presentation/register_screen.dart` (sin errores nuevos; 1 info de lint preexistente).

- Fecha: 2026-05-23
- Categoria: Auth | Android | Firebase
- Cambio: Se corrige el flujo `signInWithApple` en Flutter para Android/Web añadiendo `webAuthenticationOptions` (requerido por `sign_in_with_apple`) y validación defensiva de configuración. El `clientId` se lee desde `--dart-define=APPLE_SERVICE_ID` y el `redirectUri` desde `--dart-define=APPLE_REDIRECT_URI` o fallback a `https://<projectId>.firebaseapp.com/__/auth/handler`.
- Impacto: Se elimina el crash/excepción `webAuthenticationOptions argument must be provided on Android` y el flujo falla de forma controlada si falta configuración de Apple.
- Evidencia: lib/data/repositories/auth_repository.dart, `flutter analyze lib/data/repositories/auth_repository.dart` (sin nuevos errores; 1 info preexistente por API deprecada no relacionada).

- Fecha: 2026-05-23
- Categoria: Functions | IA | Rollback
- Cambio: Se revierte el modelo de analisis de suenos en Cloud Functions de `gemini-2.5-pro` a `gemini-2.5-flash` para restaurar el comportamiento previo y latencia/coste originales.
- Impacto: El backend vuelve a usar Flash como modelo principal de analisis.
- Evidencia: functions/src/index.ts.

- Fecha: 2026-05-23
- Categoria: Functions | IA | Calidad
- Cambio: Se cambia el modelo de Gemini usado por Cloud Functions de `gemini-2.5-flash` a `gemini-2.5-pro` para priorizar calidad semántica y reducir alucinaciones en el análisis de sueños.
- Impacto: Mayor calidad esperada en resumen/nota psicológica y menor deriva semántica, con posible incremento de latencia y coste por análisis.
- Evidencia: functions/src/index.ts, `npm run build` en functions.

- Fecha: 2026-05-23
- Categoria: Functions | IA | Debug
- Cambio: Se instrumentan logs de diagnóstico end-to-end para análisis de sueños. En `analyzeDream` (Functions) ahora se registran metadatos de request, salida cruda de Gemini (preview truncado), ruta de normalización usada (`first-pass|strict-pass|repair-pass`) y métricas del JSON final. En cliente (`GeminiService`) se registran payload recibido, preview de `analysisText`, resultado parseado y excepciones de callable.
- Impacto: Permite identificar si el fallo está en respuesta de Gemini, en normalización/repair backend o en parseo/consumo cliente sin romper el flujo funcional.
- Evidencia: functions/src/index.ts, lib/data/services/gemini_service.dart, `flutter analyze lib/data/services/gemini_service.dart lib/features/dreams/presentation/dream_analysis_step_screen.dart lib/features/dreams/presentation/dream_detail_screen.dart` (No issues found), `npm run build` en functions.

- Fecha: 2026-05-23
- Categoria: Firestore | UX | Dreams
- Cambio: Se corrige fallo de permisos al analizar/actualizar sueños cuando `updateDream` intentaba sincronizar `publicDreams/{dreamId}` para sueños privados. La proyección social pasa a ser best-effort: se evita `delete` si el documento no existe o pertenece a otro usuario y se ignora `permission-denied` de sincronización sin romper la actualización del sueño privado.
- Impacto: El análisis y guardado del sueño ya no fallan por errores de permisos en la colección social cuando el sueño no está publicado.
- Evidencia: lib/data/repositories/dream_repository.dart, `flutter analyze lib/data/repositories/dream_repository.dart lib/features/dreams/presentation/dream_analysis_step_screen.dart lib/features/dreams/presentation/dream_detail_screen.dart` (No issues found).

- Fecha: 2026-05-23
- Categoria: UX | Social | Profile
- Cambio: Se elimina la opcion de comentar suenos desde las tarjetas de perfil propio. En `ProfileScreen` se retira la navegacion a `CommentsScreen` y se quita el bloque UI de comentarios (icono + contador), dejando solo accion de like en la tarjeta publicada. Se verifica que en perfil publico no existe accion de comentarios activa.
- Impacto: La experiencia de perfil (propio y de otros) queda alineada sin entry points de comentarios en la interfaz social de suenos.
- Evidencia: lib/features/profile/presentation/profile_screen.dart, lib/features/social/presentation/public_profile_screen.dart, `flutter analyze lib/features/profile/presentation/profile_screen.dart lib/features/social/presentation/public_profile_screen.dart`.

- Fecha: 2026-05-23
- Categoria: UX | IA | Dreams
- Cambio: Se unifica el flujo de analisis IA del formulario de creacion con el flujo de detalle. `DreamAnalysisStepScreen` deja de parsear manualmente la respuesta callable y pasa a usar `GeminiService.analyzeDream` + `AnalysisLanguageUtils.coerceToLocale/alignWithDreamSignals`, igual que `DreamDetailScreen`.
- Impacto: Se elimina la deriva entre pantallas y se reduce el riesgo de resultados parcialmente vacios por diferencias de parseo/normalizacion entre flujos.
- Evidencia: lib/features/dreams/presentation/dream_analysis_step_screen.dart, `flutter analyze lib/features/dreams/presentation/dream_analysis_step_screen.dart lib/features/dreams/presentation/dream_detail_screen.dart` (No issues found).

- Fecha: 2026-05-23
- Categoria: UX | Dashboard | Data Insights
- Cambio: La tarjeta de correlación del dashboard migra de detección por palabras clave en texto libre a señales estructuradas de IA extraídas de `aiAnalysis`/`aiAnalysisByLanguage` (categoría, emociones, personajes, lugares y temas). Se elimina el factor textual de notas de contexto para este cálculo y se mantiene la correlación point-biserial sobre `moodScore`.
- Impacto: Mayor coherencia semántica con el flujo Gemini-only, menor ruido por variaciones de redacción y resultados más alineados con entidades canónicas del análisis.
- Evidencia: lib/features/dashboard/presentation/dashboard_screen.dart, `flutter analyze lib/features/dashboard/presentation/dashboard_screen.dart` (No issues found).

- Fecha: 2026-05-23
- Categoria: Functions | IA | Firestore
- Cambio: Se añade postproceso en `analyzeDream` para unificar etiquetas de facetas por usuario usando historial de los últimos 100 sueños (`users/{uid}/dreams` ordenado por `createdAt desc`). La unificación se limita a `emotions`, `characters`, `places` y `themes`, aplicando matching conservador por normalización (lowercase/trim/sin acentos), singular/plural simple y diccionario mínimo de sinónimos ES/EN. Cuando hay match, se reutiliza la forma histórica canónica y se eliminan duplicados preservando orden.
- Impacto: Reduce duplicados por variantes/sinónimos en analítica IA y mejora consistencia longitudinal de etiquetas sin alterar `summary`, `category`, `sentiment` ni `psychologicalNote`.
- Evidencia: functions/src/index.ts, `npm run build` en functions (EXIT 0).

- Fecha: 2026-05-23
- Categoria: UX | Dashboard | IA
- Cambio: Se reemplaza el tooltip de ayuda en "Etiquetas más usadas" por un dropdown de facetas (Todas, Personajes, Lugares, Emociones, Temas). El ranking deja de depender solo de `dream.tags` y pasa a agregarse desde `aiAnalysis`/`aiAnalysisByLanguage` por tipo estructurado.
- Impacto: El dashboard permite explorar elementos recurrentes por semantica real del analisis y ya no mezcla el ranking genérico de etiquetas con los campos estructurados del sueño.
- Evidencia: lib/features/dashboard/presentation/dashboard_screen.dart, `flutter analyze lib/features/dashboard/presentation/dashboard_screen.dart` (No issues found).

- Fecha: 2026-05-22
- Categoria: IA | Functions | UX
- Cambio: Se cambia el flujo de analisis a modo Gemini-only. En backend (`analyzeDream`) se elimina la generacion local de respuestas fallback y se agrega reparacion de JSON con un segundo prompt a Gemini; si no se puede normalizar respuesta, se devuelve error real. En cliente se elimina la sustitucion heuristica/fallback local durante guardado y se exige contenido minimo del resultado Gemini.
- Impacto: El analisis mostrado en app proviene exclusivamente de Gemini; se evitan respuestas prefabricadas locales y se visibilizan fallos reales de servicio/cuota/formato.
- Evidencia: functions/src/index.ts, lib/features/dreams/presentation/dream_analysis_step_screen.dart, `flutter analyze ...` (No issues found), `npm run build` en functions (BUILD_EXIT=0).

- Fecha: 2026-05-22
- Categoria: UX | IA | Resiliencia
- Cambio: Se agrega un bypass en cliente para respuestas legacy genericas de Morfeo ("necesita mas detalles" / "relato breve o insuficiente"). Si se detectan esas frases, la app rehace el resultado con analisis heuristico sobre el texto real del sueno.
- Impacto: Evita que la UI muestre resultados genericos cuando el backend devuelva fallback antiguo y permite analisis util sin depender de despliegue inmediato de Functions.
- Evidencia: lib/features/dreams/presentation/dream_analysis_step_screen.dart, lib/shared/utils/analysis_language_utils.dart, `flutter analyze ...` (No issues found).

- Fecha: 2026-05-22
- Categoria: UX | IA | Functions
- Cambio: Se reduce el umbral de coherencia para analisis de Morfeo en cliente y backend. Ahora solo se fuerza fallback cuando el texto es claramente ilogico (caracteres repetidos, tokens repetitivos extremos o densidad de letras anomala), y en el resto se devuelve lectura basica en lugar de "necesita mas detalles".
- Impacto: Disminuyen los falsos negativos de analisis en suenos reales no estructurados; Morfeo analiza practicamente todos los casos salvo entrada basura evidente.
- Evidencia: lib/features/dreams/presentation/dream_analysis_step_screen.dart, functions/src/index.ts, `flutter analyze lib/features/dreams/presentation/dream_analysis_step_screen.dart` (No issues found), `npm run build` en functions (BUILD_EXIT=0).

- Fecha: 2026-05-22
- Categoria: UX | IA | L10n
- Cambio: Se corrige el término `sonador` a `soñador` en los fallbacks/heurísticas de análisis de Morfeo y se añade normalización defensiva para que resultados antiguos sigan mostrándose correctamente en la UI.
- Impacto: La sección de personajes ya muestra `soñador` con ñ tanto en nuevos análisis como en datos heredados generados antes del fix.
- Evidencia: functions/src/index.ts, lib/shared/utils/analysis_language_utils.dart, lib/features/dreams/presentation/dream_morfeo_result_screen.dart, `flutter analyze lib/shared/utils/analysis_language_utils.dart lib/features/dreams/presentation/dream_morfeo_result_screen.dart` (EXIT 0), `npm run build` en functions (EXIT 0).

- Fecha: 2026-05-22
- Categoria: UX | Profile | Feedback
- Cambio: Se rediseña el feedback al cambiar la foto de perfil en `edit_profile_screen` con snackbar flotante estilo glass, iconografía contextual (cámara/error), borde acorde al estado y reemplazo del feedback previo básico.
- Impacto: El usuario recibe una confirmación visual más clara y consistente con la estética premium de la app al actualizar el avatar.
- Evidencia: lib/features/settings/presentation/edit_profile_screen.dart, `flutter analyze lib/features/settings/presentation/edit_profile_screen.dart` (EXIT 0, sin issues).

- Fecha: 2026-05-22
- Categoria: Notifications | Functions | UX
- Cambio: Implementacion end-to-end de notificaciones: se anaden triggers FCM para nuevas solicitudes de seguimiento (`followRequests`) y nuevos seguidores (`follows`) respetando preferencias `notifyFollowRequests` y `notifyNewFollowers`; se mantiene notificacion de publicaciones. En cliente Flutter se implementa programacion local del recordatorio diario por hora (`notificationTime`) con sincronizacion automatica por usuario autenticado.
- Impacto: La app ahora cubre publicaciones, solicitudes, nuevos seguidores y recordatorio diario de suenos de forma funcional.
- Evidencia: functions/src/index.ts, lib/data/services/notification_service.dart, lib/app/bootstrap.dart, pubspec.yaml, `flutter analyze ...` (EXIT 0), `npm run build` en functions (EXIT 0).


- Fecha: 2026-05-22
- Categoria: UX | IA | Audio
- Cambio: Se ajusta el flujo de analisis de Morfeo para que un fallo de transcripcion por cuota/servicio agotado no corte el proceso cuando ya existe titulo y descripcion. En ese caso se continua con analisis de texto solamente.
- Impacto: Los sueños con descripcion suficiente ya no quedan bloqueados por el audio si Gemini devuelve 429 o un error de disponibilidad.
- Evidencia: lib/features/dreams/presentation/dream_analysis_step_screen.dart, `flutter analyze lib/features/dreams/presentation/dream_analysis_step_screen.dart` (EXIT 0, sin issues).

- Fecha: 2026-05-22
- Categoria: UX | Dreams | Sharing
- Cambio: Ajustes en `dream_saved_step_screen`: en la tarjeta de publicacion se movio el estado (`Publicado` / `Pendiente de publicar`) a una linea propia para evitar que el titulo se comprima; en la seccion de compartir se elimino el acceso dedicado a WhatsApp y se dejo una unica accion de compartir general.
- Impacto: Mejor legibilidad del bloque de publicacion y flujo de compartir mas limpio y consistente.
- Evidencia: lib/features/dreams/presentation/dream_saved_step_screen.dart, `flutter analyze lib/features/dreams/presentation/dream_saved_step_screen.dart` (EXIT 0, sin issues).

- Fecha: 2026-05-22
- Categoria: Functions | IA | Resiliencia
- Cambio: Se endurece `analyzeDream` para que los fallos de Gemini no se propaguen como error interno al cliente. Cuando la llamada falla o no hay texto util, la Function devuelve un analisis basico con `quality: low` en lugar de lanzar `HttpsError('internal')`.
- Impacto: Morfeo deja de romper el flujo de guardado/análisis para sueños con contenido valido pero respuestas problemáticas del modelo o de la API.
- Evidencia: functions/src/index.ts, `npm run build` en functions (EXIT 0).

- Fecha: 2026-05-22
- Categoria: Firebase | Notifications | Android
- Cambio: Se corrige la entrega de notificaciones push para publicaciones sociales. `appBootstrap` ahora crea el canal Android `social_notifications`, vuelve a sincronizar el token FCM cuando el usuario inicia sesion despues del arranque y se agrega `POST_NOTIFICATIONS` al manifest de Android.
- Impacto: Los usuarios autenticados ya no dependen de arrancar la app con sesion activa para registrar el token, y Android 13+ puede pedir el permiso correcto para recibir push en release APK.
- Evidencia: lib/app/bootstrap.dart, android/app/src/main/AndroidManifest.xml, `flutter analyze lib/app/bootstrap.dart android/app/src/main/AndroidManifest.xml` (EXIT 0, sin issues).

- Fecha: 2026-05-22
- Categoria: UX | IA | Audio
- Cambio: Se relaja la validacion client-side de transcripcion en `dream_analysis_step_screen.dart`. El flujo de Morfeo deja de bloquear audios con texto corto pero valido y solo muestra la advertencia de informacion insuficiente cuando no se obtiene ninguna transcripcion.
- Impacto: Los audios largos que Gemini transcribe de forma breve ya no quedan cortados antes del analisis; el flujo continua hacia interpretacion y fallback basico si hace falta.
- Evidencia: lib/features/dreams/presentation/dream_analysis_step_screen.dart, `flutter analyze lib/features/dreams/presentation/dream_analysis_step_screen.dart` (EXIT 0, sin issues).

- Fecha: 2026-05-22
- Categoria: UX | Auth | Registro
- Cambio: Se anade popup de confirmacion al completar registro en `RegisterScreen`. Tras `signUp` exitoso ahora se muestra un modal de exito (icono, mensaje localizado y CTA a login) antes del `signOut` y redireccion a pantalla de inicio de sesion.
- Impacto: El usuario recibe feedback claro de alta correcta y el flujo de paso a login queda mas comprensible.
- Evidencia: lib/features/auth/presentation/register_screen.dart, `flutter analyze lib/features/auth/presentation/register_screen.dart` (EXIT 0, sin issues).

- Fecha: 2026-05-22
- Categoria: UX | Onboarding | Navigation
- Cambio: Correccion del tutorial guiado en `MainShell` tras incidencia visual: el overlay ahora se renderiza por encima de todo el `Scaffold` (incluyendo footer/nav inferior), se asegura `key` en el tab de Dashboard para target consistente, y se unifica la posicion vertical de la tarjeta informativa entre pasos.
- Impacto: El remarcado del menu inferior vuelve a ser visible y el paso de Dashboard ya no desplaza el recuadro a una posicion distinta respecto al resto.
- Evidencia: lib/app/main_shell.dart, `flutter analyze lib/app/main_shell.dart` (EXIT 0, sin issues).

- Fecha: 2026-05-22
- Categoria: UX | Auth | Registro
- Cambio: Ajustado flujo post-registro para no entrar directamente a la app. Tras `signUp` exitoso en RegisterScreen ahora se ejecuta `signOut` y se redirige a la ruta de login (`/login`) en lugar de Home.
- Impacto: El usuario queda obligado a iniciar sesion manualmente despues de crear cuenta, alineando el comportamiento esperado del onboarding de autenticacion.
- Evidencia: lib/features/auth/presentation/register_screen.dart, `flutter analyze lib/features/auth/presentation/register_screen.dart` (No issues found).

- Fecha: 2026-05-22
- Categoria: Branding | UX | Build
- Cambio: Actualizada identidad visible de la app a HypnOS en Android, iOS, Web, Windows, Linux y macOS. Se genero un icono launcher oficial desde el MorpheusOrbPainter (orbe real usado en UI) mediante un script Flutter y luego se regeneraron iconos multiplataforma con flutter_launcher_icons.
- Impacto: Nombre de app consistente en dispositivo/plataformas y logo de launcher alineado con el orbe de Morfeo usado dentro de la aplicacion.
- Evidencia: pubspec.yaml, android/app/src/main/AndroidManifest.xml, ios/Runner/Info.plist, web/index.html, web/manifest.json, windows/runner/main.cpp, windows/runner/Runner.rc, linux/runner/my_application.cc, macos/Runner/Configs/AppInfo.xcconfig, tool/generate_orb_icon_test.dart, assets/icons/morpheus_orb_launcher.png, `dart run flutter_launcher_icons` (EXIT 0).

- Fecha: 2026-05-22
- Categoria: UX | Auth | Login
- Cambio: Rediseño del popup de confirmacion para restablecer contrasena en inicio de sesion. Se reemplazo `AlertDialog` basico por modal custom (fondo oscuro, borde/glow tonal, icono de correo, jerarquia tipografica y CTA principal `Enviar enlace`).
- Impacto: Flujo de recuperacion de cuenta mas claro y consistente con el lenguaje visual premium del resto de modales de la app.
- Evidencia: lib/features/auth/presentation/login_screen.dart, `flutter analyze lib/features/auth/presentation/login_screen.dart` (sin errores; 1 info de lint preexistente).

- Fecha: 2026-05-21
- Categoria: UX | Onboarding | Home
- Cambio: Implementado tutorial guiado de primera entrada en `MainShell` con overlay oscuro, foco resaltado sobre opciones principales (tabs y FAB), panel explicativo con orbe de Morfeo, progreso por pasos y boton `Saltar tutorial`. El estado de visto se persiste por usuario en `SharedPreferences` (`main_tutorial_seen_{uid}`).
- Impacto: Mejora onboarding inicial al explicar de forma contextual para que sirve cada seccion y como empezar a usar la app, sin repetirse en futuras sesiones.
- Evidencia: lib/app/main_shell.dart, `flutter analyze lib/app/main_shell.dart` (EXIT 0, sin issues).

- Fecha: 2026-05-21
- Categoria: UX | Home | Social
- Cambio: Se anade una seccion al final de Inicio con suenos publicados de usuarios seguidos. La UI escucha `follows` del usuario actual y renderiza feed en tiempo real desde `publicDreams` (ordenado por `publishedAt`) con fecha, titulo y preview.
- Impacto: Inicio incorpora consumo social directo sin salir de la pantalla principal, mostrando actividad reciente de cuentas seguidas.
- Evidencia: lib/features/home/presentation/home_screen.dart, `flutter analyze lib/features/home/presentation/home_screen.dart` (EXIT 0, sin issues).

- Fecha: 2026-05-21
- Categoria: UX | Social | Firestore
- Cambio: Se elimina la opcion de comentar suenos en vistas sociales y se refactoriza el flujo de likes para evitar errores de permisos. `likeDream/unlikeDream` ahora operan solo sobre `publicDreams/{dreamId}/likes/{uid}` (sin actualizar contadores en el documento padre). En DreamDetail y perfil publico el conteo de likes pasa a leerse desde la subcoleccion `likes`, y el detalle publico incorpora accion de like para suenos de terceros.
- Impacto: Desaparecen errores de `PERMISSION_DENIED` al dar like por writes no permitidos al documento padre de `publicDreams`; los usuarios pueden dar like desde el detalle de suenos de terceros; se retira completamente la opcion de comentarios en UI.
- Evidencia: lib/data/repositories/social_repository.dart, lib/features/dreams/presentation/dream_detail_screen.dart, lib/features/social/presentation/public_profile_screen.dart, `flutter analyze ...` (EXIT 0, sin issues).

- Fecha: 2026-05-21
- Categoria: UX | Social | Dreams
- Cambio: Mejora de lectura de suenos en perfil publico. Las tarjetas ahora recortan descripcion con sufijo explicito `...` cuando excede el limite y al tocar una tarjeta se abre una vista de detalle publico con fecha, titulo, descripcion completa y reproductores de audio.
- Impacto: El usuario puede previsualizar mejor contenido truncado y acceder al contenido completo del sueno publicado sin perder contexto.
- Evidencia: lib/features/social/presentation/public_profile_screen.dart, `flutter analyze lib/features/social/presentation/public_profile_screen.dart` (EXIT 0, sin issues).

- Fecha: 2026-05-21
- Categoria: UX | Social
- Cambio: Rediseno del popup de "Eliminar seguidor" para alinearlo con los modales de seguridad de cuenta (fondo oscuro translúcido, borde y glow tonal, icono de advertencia, jerarquia tipografica y botones outlined/primario).
- Impacto: Mayor consistencia visual entre flujos criticos de cuenta y social, con mejor percepcion de confirmacion destructiva.
- Evidencia: lib/features/social/presentation/follow_users_list_screen.dart, validacion estatica sin errores en el archivo.

 Fecha: 2026-05-21
 Categoria: UX | L10n | Dreams
 Cambio: Correccion de localizacion en categoria IA pendiente para DreamDetail. Se evita guardar placeholders traducidos en `aiCategory` al crear suenos sin analisis (`aiCategory: null`) y se normalizan placeholders legacy en lectura UI (`Pending AI categorization` / `Pendiente de categorizacion ia`) para mostrar siempre `dreamDetailAiCategoryPending` del idioma activo.
 Impacto: En app en espanol deja de mostrarse texto en ingles para suenos no analizados, incluso con datos antiguos ya persistidos.
 Evidencia: lib/features/dreams/presentation/dream_analysis_step_screen.dart, lib/features/dreams/presentation/dream_detail_screen.dart, `flutter analyze lib/features/dreams/presentation/dream_analysis_step_screen.dart lib/features/dreams/presentation/dream_detail_screen.dart` (EXIT 0, sin issues).

- Fecha: 2026-05-21
- Categoria: UX | Social | Firestore
- Cambio: Se anade accion para eliminar seguidores desde la lista de seguidores del perfil propio. En `FollowUsersListScreen` se incorpora menu por usuario con `Eliminar seguidor` + confirmacion y estado de carga por fila. En capa de datos se agrega `removeFollower(currentUserId, followerUserId)` en `SocialRepository` para borrar la relacion `follows/{followerId}_{currentUserId}`.
- Impacto: El usuario puede moderar su lista de seguidores directamente desde la UI sin depender de que el seguidor deje de seguir manualmente.
- Evidencia: lib/features/social/presentation/follow_users_list_screen.dart, lib/data/repositories/social_repository.dart, `flutter analyze lib/features/social/presentation/follow_users_list_screen.dart lib/data/repositories/social_repository.dart` (EXIT 0, sin issues).

- Fecha: 2026-05-21
- Categoria: Firestore | UX | Social
- Cambio: Correccion de consistencia en "suenos publicados" del perfil. `DreamRepository.updateDream` ahora sincroniza la proyeccion `publicDreams/{dreamId}` despues de cada actualizacion: crea/mergea cuando `isPublished=true` (preservando `publishedAt`, `likesCount`, `commentsCount`) y elimina cuando se despublica. Ademas, el perfil propio migra su listado/contador de publicados a la fuente canonica `users/{uid}/dreams` filtrando `isPublished=true` en cliente.
- Impacto: Un sueno recien publicado vuelve a aparecer inmediatamente en el perfil del autor, incluso si la proyeccion social previa estaba incompleta; se reduce la deriva entre el documento canonico y la copia social.
- Evidencia: lib/data/repositories/dream_repository.dart, lib/features/profile/presentation/profile_screen.dart, `flutter analyze lib/data/repositories/dream_repository.dart lib/features/profile/presentation/profile_screen.dart` (EXIT 0, sin issues).

- Fecha: 2026-05-21
- Categoria: Functions | Social
- Cambio: Reconstruccion del entrypoint de Cloud Functions (`functions/src/index.ts`) sobre un contrato callable limpio y compilable. Se restauraron `analyzeDream`, `transcribeAudio` y `notifyFollowerOnDreamPublish`, y se anadieron triggers Firestore `incrementFollowCounters` y `decrementFollowCounters` para mantener `followersCount` y `followingCount` sincronizados al crear/eliminar relaciones en `follows`.
- Impacto: El backend vuelve a ser desplegable y los contadores denormalizados de seguidores/seguidos quedan alineados con el flujo social del cliente sin depender solo de consultas live en UI.
- Evidencia: functions/src/index.ts, `npm run build` en functions exitoso.

- Fecha: 2026-05-21
- Categoria: UX | Social | Publicaciones
- Cambio: Correccion del flujo social de seguimiento y publicacion en cliente Flutter. Se elimino la caida de casos en el boton de seguir/dejar de seguir/solicitar de perfil publico, se hizo reactivo el estado `following|pending|none` escuchando en paralelo `follows` y `followRequests`, y se migraron los contadores visibles (seguidores, siguiendo y publicaciones) a consultas en tiempo real sobre `follows` y `publicDreams` en lugar de depender de campos denormalizados en `users`.
- Impacto: Los contadores se actualizan inmediatamente tras solicitar, aceptar, rechazar o dejar de seguir; el boton de follow ejecuta una sola accion por toque; y el contador de publicaciones refleja solo suenos realmente publicados.
- Evidencia: lib/features/social/presentation/public_profile_screen.dart, lib/data/repositories/social_repository.dart, lib/features/profile/presentation/profile_screen.dart, `flutter analyze` sobre los 3 archivos (sin errores/warnings, 1 info de estilo no bloqueante).

- Fecha: 2026-05-21
- Categoria: UX | Settings
- Cambio: Control de desborde del correo en la seccion de credenciales de ajustes: el valor de email ahora usa ancho maximo, una sola linea y `TextOverflow.ellipsis` para mostrar `...` cuando no cabe.
- Impacto: Evita roturas visuales en pantallas pequenas o correos largos y mantiene la fila de seguridad consistente.
- Evidencia: lib/features/settings/presentation/account_security_screen.dart, validacion estatica sin errores en el archivo.

- Fecha: 2026-05-21
- Categoria: UX | Dashboard | Correlaciones
- Cambio: Refactor del umbral minimo para calcular correlaciones por rango temporal: semana pasa a requerir 3 suenos con intensidad (antes 8), mes mantiene 8. El texto de estado cuando no hay suficientes datos ahora incluye explicitamente el minimo requerido segun rango.
- Impacto: La vista semanal genera correlaciones con menos friccion y el mensaje de insuficiencia de datos comunica un criterio cuantitativo claro al usuario.
- Evidencia: lib/features/dashboard/presentation/dashboard_screen.dart, validacion estatica sin errores en el archivo.

- Fecha: 2026-05-21
- Categoria: UX | Dashboard
- Cambio: Mejora visual del texto en tooltips de "Categorias mas frecuentes" y "Etiquetas mas usadas": tipografia definida (tamano, peso, altura), padding personalizado y contenedor con borde/glow tonal por seccion.
- Impacto: Mayor legibilidad del contenido explicativo y mejor coherencia visual con el lenguaje glassmorphism del dashboard.
- Evidencia: lib/features/dashboard/presentation/dashboard_screen.dart, validacion estatica sin errores en el archivo.

- Fecha: 2026-05-21
- Categoria: UX | Settings
- Cambio: Rediseño del popup de confirmacion para restablecer contrasena (`_sendPasswordReset`) con modal custom consistente con los dialogos recientes: icono central, contenedor con borde/glow, copy centrado y acciones en fila (Cancelar / Enviar enlace).
- Impacto: Mayor coherencia visual en la seccion de seguridad y mejor claridad de accion antes de enviar el email de recuperacion.
- Evidencia: lib/features/settings/presentation/account_security_screen.dart, validacion estatica sin errores en el archivo.

- Fecha: 2026-05-21
- Categoria: UX | Settings
- Cambio: Rediseño del popup de confirmacion de cierre de sesion en AccountSecurityScreen con estilo visual alineado al modal de eliminacion de cuenta (dialog custom con icono central, borde glow y layout de botones), simplificado a dos acciones "Cancelar" y "Aceptar", sin solicitud de contrasena y con acento amarillo en lugar de rojo.
- Impacto: Coherencia visual entre acciones criticas y flujo de cierre de sesion mas directo para el usuario.
- Evidencia: lib/features/settings/presentation/account_security_screen.dart, validacion estatica sin errores en el archivo.

- Fecha: 2026-05-21
- Categoria: UX | Dreams
- Cambio: Alineacion cromatica del slider de intensidad en el formulario de sueno: la barra usa gradiente con los 5 colores oficiales de `IntensityUtils` (niveles 1..5) y el glow/overlay del thumb adopta el color de la intensidad seleccionada.
- Impacto: Consistencia visual completa entre control de entrada y codificacion de intensidad usada en tarjetas, chips y graficos.
- Evidencia: lib/features/dreams/presentation/dream_form_screen.dart, validacion estatica sin errores en el archivo.

- Fecha: 2026-05-21
- Categoria: UX | Dashboard
- Cambio: Se anaden tooltips informativos en "Categorias IA mas frecuentes" y "Etiquetas mas usadas" para explicar significado y criterio de conteo; ademas se excluyen tags de intensidad (`mood:1..5`) del bloque de etiquetas mas usadas.
- Impacto: Mayor claridad semantica para el usuario y limpieza del ranking de etiquetas recurrentes, evitando ruido por tags tecnicos de intensidad.
- Evidencia: lib/features/dashboard/presentation/dashboard_screen.dart, validacion estatica sin errores en el archivo.

- Fecha: 2026-05-21
- Categoria: Dashboard | Data Insights
- Cambio: Evolucion del bloque "Correlacion" en Dashboard desde heuristica por promedio a asociaciones estadisticas por factor usando coeficiente point-biserial sobre intensidad emocional (`moodScore`). Se incorporan factores detectados en texto/tags/categoria/notas de contexto y ranking Top-3 con direccion, fuerza, confianza y tamano de muestra.
- Impacto: La seccion deja de mostrar un mensaje generico y pasa a ofrecer correlaciones medibles, mas alineadas con el objetivo de deteccion de patrones de la app.
- Evidencia: lib/features/dashboard/presentation/dashboard_screen.dart, `flutter analyze lib/features/dashboard/presentation/dashboard_screen.dart` (EXIT 0, sin issues).

- Fecha: 2026-05-21
- Categoria: UX | Dashboard
- Cambio: Ajuste de tarjetas de resumen en Dashboard: promedio de intensidad ahora se muestra redondeado (1..5) con etiqueta textual equivalente y color segun IntensityUtils; la metrica de IA se renombra a "Analizados por Morfeo" y el valor incorpora reborde morado.
- Impacto: Lectura mas clara del estado emocional promedio y mayor consistencia de marca Morfeo en metricas clave.
- Evidencia: lib/features/dashboard/presentation/dashboard_screen.dart, validacion estatica sin errores en el archivo.

- Fecha: 2026-05-21
- Categoria: UX | Dashboard
- Cambio: Reemplazo del bloque "Suenos por semana" por un calendario mensual completo en Dashboard. Los dias con sueno se resaltan con circulo azul y cada fila semanal incorpora un contador lateral con total de suenos de esa semana.
- Impacto: Mejora de legibilidad temporal al mostrar el mes completo (incluyendo dias sin registros) y facilita comparacion semanal directa sin depender de barras.
- Evidencia: lib/features/dashboard/presentation/dashboard_screen.dart, `flutter analyze lib/features/dashboard/presentation/dashboard_screen.dart` (EXIT 0, sin issues).

- Fecha: 2026-05-21
- Categoria: UX | IA
- Cambio: Ajuste del bloque Morfeo en DreamDetail: reemplazo de orbe estatico por orbe animado reutilizado del sistema visual y etiquetado dinamico del CTA para mostrar "Volver a ejecutar analisis IA" cuando existe analisis previo.
- Impacto: Mayor consistencia visual con pantallas de Analisis/Publicacion y feedback mas claro al usuario sobre reanalisis.
- Evidencia: lib/features/dreams/presentation/dream_detail_screen.dart, validacion estatica sin errores en el archivo.

- Fecha: 2026-05-21
- Categoria: UX | IA
- Cambio: Rediseno visual de DreamDetailScreen con cabecera reforzada, tarjeta narrativa, tarjeta de metadatos, bloque Morfeo con gradiente morado, visualizacion generada abstracta y acciones inferiores mas cohesionadas con el lenguaje visual de analisis/publicacion.
- Impacto: El detalle del sueno gana jerarquia, coherencia visual y una lectura mas cercana a la referencia compartida sin cambiar el modelo de datos ni el flujo de navegacion.
- Evidencia: lib/features/dreams/presentation/dream_detail_screen.dart, validacion estatica sin errores en el archivo.

- Fecha: 2026-05-21
- Categoria: UX | Dashboard | Analitica
- Cambio: Rediseno funcional de Dashboard para priorizar lectura de datos disponibles en `Dream`: nuevo resumen numerico (total, este mes, intensidad promedio, analizados IA), evolucion de intensidad con encabezado actualizado, grafica de suenos por semana (6 semanas), top categorias IA y top tags; se mantiene panel de insight Morfeo al inicio y correlacion al final.
- Impacto: Mejor jerarquia informativa y escaneabilidad de patrones sin cambiar providers, navegacion ni estilo visual glassmorphism existente.
- Evidencia: lib/features/dashboard/presentation/dashboard_screen.dart, `flutter analyze lib/features/dashboard/presentation/dashboard_screen.dart` (EXIT 0, sin issues).

- Fecha: 2026-05-21
- Categoria: Arquitectura | IA | L10n
- Cambio: Persistencia del analisis de Morfeo por idioma en cliente Flutter. Se agrega `aiAnalysisByLanguage` en el modelo de sueno, guardado por locale (`es`/`en`) al crear con analisis y merge por locale al reanalizar desde detalle. En DreamDetail se prioriza lectura por idioma actual con fallback legacy a `aiAnalysis` y se incorpora auto-analisis silencioso al detectar ausencia del idioma actual cuando existen analisis en otro idioma.
- Impacto: El usuario ve analisis coherente con el idioma activo y los documentos conservan compatibilidad con datos antiguos (`aiAnalysis`) mientras migran progresivamente a almacenamiento multilenguaje.
- Evidencia: lib/data/models/dream_model.dart, lib/features/dreams/presentation/dream_analysis_step_screen.dart, lib/features/dreams/presentation/dream_detail_screen.dart, `flutter analyze ...` sin errores.

- Fecha: 2026-05-21
- Categoria: Functions | IA | UX
- Cambio: Hardening transversal del flujo Morfeo para evitar exitos vacios. En backend `analyzeDream` se anadio normalizacion de salida, validacion de contenido minimo y fallback estructurado para respuestas vacias/no estructuradas y para entrada incoherente. En cliente se mejoro el parser tolerante y se anadio fallback local si el parseo produce analisis sin contenido util.
- Impacto: El analisis deja de llegar vacio sin error visible y siempre devuelve una salida util minima; los textos sin sentido se manejan como "datos insuficientes" con respuesta basica en lugar de fallo silencioso.
- Evidencia: functions/src/index.ts, lib/data/services/gemini_service.dart, lib/features/dreams/presentation/dream_analysis_step_screen.dart, `flutter analyze ...` sin errores, `npm run build` en functions exitoso.

- Fecha: 2026-04-29
- Categoria: Agentes
- Cambio: Creacion de dos archivos compartidos para contexto global e historial de ciclo de vida.
- Impacto: Base comun para agentes actuales y futuros y mejor trazabilidad para el TFG.
- Evidencia: .github/agents/contexts/shared/shared-app-context.md, .github/agents/contexts/shared/shared-lifecycle-history.md

- Fecha: 2026-04-29
- Categoria: Arquitectura
- Cambio: Sintesis extrema del contexto funcional/tecnico de la app en shared-app-context.
- Impacto: Contexto mas corto, accionable y consistente para decisiones de todos los agentes.
- Evidencia: .github/agents/contexts/shared/shared-app-context.md

- Fecha: 2026-04-30
- Categoria: Firestore | Storage
- Cambio: Reemplazado modo test por reglas de seguridad reales en Firestore y Storage. firebase.json actualizado para referenciar los archivos de reglas. Creado firestore.indexes.json vacio.
- Impacto: Acceso denegado por defecto; cada usuario solo accede a sus propios documentos y archivos de audio. Validaciones basicas de campos en writes. Principio de minimo privilegio aplicado.
- Evidencia: firestore.rules, storage.rules, firestore.indexes.json, firebase.json

- Fecha: 2026-04-29
- Categoria: Agentes
- Cambio: Creacion de arquitectura multiagente coordinada con 4 agentes especialistas y un documento de coordinacion transversal.
- Impacto: Mejor reparto de responsabilidades, delegacion explicita por dominio y menor riesgo de solapamientos.
- Evidencia: .github/agents/flutter-ux-app.agent.md, .github/agents/firebase-backend-security.agent.md, .github/agents/qa-release.agent.md, .github/agents/data-insights.agent.md, .github/agents/contexts/shared/shared-agent-coordination.md

- Fecha: 2026-04-29
- Categoria: Agentes
- Cambio: Creacion de documentos operativos por dominio para UX, backend, QA y metrica, y actualizacion de agentes existentes para coordinacion.
- Impacto: Estandar operativo por agente y mayor consistencia de ejecucion entre tareas.
- Evidencia: .github/agents/contexts/specialized/flutter-ux-style-context.md, .github/docs/guides/firebase-backend-runbook.md, .github/docs/checklists/qa-release-checklist.md, .github/agents/contexts/specialized/data-insights-metric-context.md, .github/agents/infra-mobile-firebase-ai.agent.md, .github/agents/gestor-agentes-copilot.agent.md

- Fecha: 2026-04-29
- Categoria: Agentes
- Cambio: Refinamiento del contexto UX de Flutter con sistema visual completo (tokens, tipografia, movimiento), especificaciones por pantalla (Home, Captura, Analisis) y criterios de aceptacion UX.
- Impacto: Guia de implementacion front mas concreta y consistente con objetivo de captura < 60s y accesibilidad en uso nocturno.
- Evidencia: .github/agents/contexts/specialized/flutter-ux-style-context.md

- Fecha: 2026-05-12
- Categoria: Arquitectura | UX
- Cambio: Rediseno visual completo de la app segun mockups de referencia. Implementado MainShell con BottomNavigationBar glassmorphism (4 tabs: Inicio, Diario, Analisis, Perfil). Creado widget GlassCard reutilizable. Redesenadas HomeScreen (hero orb + cards contextuales), DreamsListScreen (glass cards con emotion pills), DashboardScreen (panel Morfeo IA prominente + chart + chips recurrentes + correlacion), ProfileScreen (avatar + secciones de privacidad/preferencias). AuthGate redirige a MainShell.
- Impacto: Coherencia visual completa entre pantallas, Morfeo presente en analisis, navegacion por pestanas en lugar de hub de botones.
- Evidencia: lib/app/main_shell.dart, lib/shared/widgets/glass_card.dart, lib/features/home/presentation/home_screen.dart, lib/features/dreams/presentation/dreams_list_screen.dart, lib/features/dashboard/presentation/dashboard_screen.dart, lib/features/profile/presentation/profile_screen.dart



- Fecha: 2026-04-29
- Categoria: Arquitectura
- Cambio: Creacion de un documento operativo de planificacion de sprints con fases, criterios de salida y plantilla de validacion con Product Owner.
- Impacto: Estandariza el proceso incremental de entrega y validacion al cierre de cada sprint.
- Evidencia: .github/docs/plans/sprint-development-plan.md

- Fecha: 2026-04-29
- Categoria: Arquitectura
- Cambio: Inicio formal de Fase 1 con definicion de Sprint 1 y creacion del entregable base de analisis/diseno (prototipo, datos y arquitectura).
- Impacto: Se habilita ejecucion guiada del sprint con criterios de aceptacion y base tecnica para arrancar Fase 2 sin ambiguedad.
- Evidencia: .github/docs/plans/sprint-development-plan.md, .github/docs/reports/phase-1-analysis-design-deliverable.md

- Fecha: 2026-04-30
- Categoria: Firebase
- Cambio: Preparacion de infraestructura Firebase para Fase 2 con reglas de seguridad, documentacion y guia de integracion Flutter.
- Impacto: Backend seguro y listo para Sprint 2 con least-privilege access control, validacion de datos y ownership-based authorization.
- Evidencia: .github/firebase/firestore.rules, .github/firebase/storage.rules, .github/firebase/firebase-phase2-setup.md, .github/firebase/security-validation-tests.md, .github/firebase/flutter-backend-integration.md

- Fecha: 2026-04-30
- Categoria: Arquitectura
- Cambio: Creacion de estructura base Flutter con Repository Pattern, modelos de dominio, servicios Firebase, y capa de datos completa.
- Impacto: Infraestructura de código lista para implementación de features sin deuda técnica. Soporta modularización por features y reutilización de código.
- Evidencia: lib/ (estructura de carpetas, modelos, repositories, services), pubspec.yaml (dependencias actualizadas con Provider + GoRouter), SETUP_GUIDE.md, INTEGRATION_RISKS.md

- Fecha: 2026-04-30
- Categoria: Arquitectura
- Cambio: Definición de modelos de dominio Dart (User, Dream, Insight) con serialización Firestore y relaciones bidireccionales.
- Impacto: Contratos claros entre Data y Presentation layers. Facilita testing y elimina ambigüedad en transformación de datos.
- Evidencia: lib/data/models/ (user_model.dart, dream_model.dart, insight_model.dart)

- Fecha: 2026-04-30
- Categoria: Arquitectura
- Cambio: Implementación de FirebaseService wrapper, AuthRepository + DreamRepository con Result<T> pattern para manejo funcional de errores.
- Impacto: Abstracción de Firebase en interfaces reutilizables. Error handling robusto sin crashes inesperados.
- Evidencia: lib/data/services/firebase_service.dart, lib/data/repositories/ (auth_repository.dart, dream_repository.dart)

- Fecha: 2026-04-30
- Categoria: Arquitectura
- Cambio: Adición de extensiones Dart reutilizables (String, DateTime, List, Map) y utilidades compartidas (validadores, formateadores).
- Impacto: Código más legible, menos boilerplate, validaciones consistentes en toda la app.
- Evidencia: lib/shared/ (extensions/extensions.dart, utils/validators_formatters.dart)

- Fecha: 2026-04-30
- Categoria: Arquitectura
- Cambio: Documentación exhaustiva de estructura del proyecto, setup, dependencias y guía para desarrollador.
- Impacto: Onboarding más rápido, referencia clara de arquitectura, reduce preguntas de implementación.
- Evidencia: SETUP_GUIDE.md (instalación, estructura, modelos, servicios), INTEGRATION_RISKS.md (riesgos y dependencias bloqueantes)

- Fecha: 2026-04-30
- Categoria: Arquitectura
- Cambio: Identificación de riesgos críticos de integración: Firebase config, Firestore rules, Audio storage, Gemini API management, Auth persistence, STT diferencias, Cloud Functions cold start.
- Impacto: Mitiga sorpresas en sprint y documenta dependencias bloqueantes por fase.
- Evidencia: INTEGRATION_RISKS.md (8 riesgos críticos, checklists de validación, propuestas de mejora)

- Fecha: 2026-04-30
- Categoria: Firebase | Arquitectura | CI/CD
- Cambio: Hardening del arranque Flutter/Firebase para plataformas no configuradas (modo degradado sin crash), ajuste de compatibilidad en capa Dream para restaurar compilación estática y creación de workflow CI mínimo con pub get + analyze + test.
- Impacto: Sprint 2 habilitado con bootstrap robusto, menor riesgo de fallo en web/desktop sin config Firebase y validación automática base en pull requests.
- Evidencia: lib/app/bootstrap.dart, lib/main.dart, lib/firebase_options.dart, lib/features/dreams/presentation/, .github/workflows/flutter-ci.yml

- Fecha: 2026-04-30
- Categoria: Auth | Firestore | Storage
- Cambio: Implementado bloque backend base de Sprint 2 con esquema de usuarios/suenos alineado a Firestore, repositorios con acceso por uid autenticado y validacion moodScore 1-5.
- Impacto: Base backend funcional y endurecida con minimo privilegio para perfil y CRUD de suenos.
- Evidencia: lib/data/models/user_model.dart, lib/data/models/dream_model.dart, lib/data/repositories/auth_repository.dart, lib/data/repositories/dream_repository.dart, firestore.rules, storage.rules

- Fecha: 2026-04-30
- Categoria: Arquitectura | Auth | UX
- Cambio: Implementado bloque UI/UX de Sprint 2 con flujo navegable Auth -> Home -> Crear/Listar/Editar/Eliminar sueno -> Perfil, formularios con validaciones y estados loading/empty/error.
- Impacto: Flujo funcional end-to-end sobre repositorios existentes, habilitando uso real de auth y CRUD de suenos con configuracion de perfil y notificaciones.
- Evidencia: lib/main.dart, lib/app/app_routes.dart, lib/features/auth/presentation/, lib/features/home/presentation/, lib/features/dreams/presentation/, lib/features/profile/presentation/, comando `flutter analyze lib`

- Fecha: 2026-05-04
- Categoria: QA
- Cambio: Creacion de checklist de QA formal para Sprint 2 con 40 verificaciones en 9 bloques (entorno, auth, home, CRUD, perfil, seguridad y UI/resolucion) y criterio de aceptacion del Product Owner.
- Impacto: Proceso de validacion objetivo para cierre de Sprint 2 y trazabilidad del incremento entregado. Util como evidencia metodologica para TFG.
- Evidencia: .github/docs/checklists/qa-sprint-2-checklist.md

- Fecha: 2026-05-04
- Categoria: CI/CD
- Cambio: Creacion de guia de despliegue paso a paso para Android Studio con configuracion de 3 emuladores (resoluciones pequena, media y grande), instrucciones de ejecucion, prueba en dispositivo fisico y comandos de build debug/release.
- Impacto: Proceso de despliegue reproducible y documentado. Reduce friccion para iniciar validacion QA. Evidencia de proceso de desarrollo para TFG.
- Evidencia: .github/docs/guides/android-studio-deploy-guide.md

- Fecha: 2026-05-04
- Categoria: UX | Arquitectura
- Cambio: Implementacion de sistema de tema centralizado para Sprint 2 (tokens de color, tipografia, espaciados y radios) y aplicacion consistente en login, registro, home, lista/formulario/detalle de suenos y perfil.
- Impacto: Eliminacion de apariencia Material por defecto, mayor coherencia visual nocturna y CTA principal mas evidente por pantalla sin cambios de logica de negocio.
- Evidencia: lib/app/theme/, lib/main.dart, lib/features/auth/presentation/, lib/features/home/presentation/, lib/features/dreams/presentation/, lib/features/profile/presentation/, comprobacion estatica en archivos modificados.

- Fecha: 2026-05-05
- Categoria: Agentes | Arquitectura
- Cambio: Reorganizacion de .github separando agentes, contextos compartidos/especializados y documentos externos (guias, checklists, planes, estatus y reportes), con actualizacion de rutas de referencia.
- Impacto: Estructura mas entendible, menor mezcla de responsabilidades y mejor mantenibilidad para agentes actuales y futuros.
- Evidencia: .github/agents/README.md, .github/agents/contexts/, .github/docs/, .github/agents/*.agent.md, .github/firebase/*.md

- Fecha: 2026-05-07
- Categoria: Arquitectura | Audio | IA
- Cambio: Implementacion de AudioService para grabacion con record y subida a Firebase Storage bajo path users/{uid}/dreams/{dreamId}/audio.m4a.
- Impacto: Base de infraestructura de audio lista para grabacion, subida y borrado. Sin crash si Storage falla (fallback graceful).
- Evidencia: lib/data/services/audio_service.dart, lib/shared/errors/exceptions.dart (PermissionException)

- Fecha: 2026-05-07
- Categoria: IA | Arquitectura
- Cambio: Implementacion de GeminiService con analisis estructurado de suenos (sentimiento, categoria, emociones, personajes, lugares, temas, nota psicologica, resumen) y soporte para transcripcion multimodal por bytes.
- Impacto: Integracion limpia con Gemini 1.5 Flash sin acoplamiento directo en UI. Parsing de respuesta estructurado en DreamAnalysis.
- Evidencia: lib/data/services/gemini_service.dart

- Fecha: 2026-05-07
- Categoria: UX | Audio
- Cambio: Implementacion de AudioRecorderWidget (grabacion con cronometro y punto pulsante) y AudioPlayerWidget (slider + tiempos + play/pause desde URL remota) como widgets reutilizables.
- Impacto: Componentes de audio listos para integrarse en cualquier pantalla. Estado de grabacion y reproduccion encapsulado.
- Evidencia: lib/shared/widgets/audio_recorder_widget.dart, lib/shared/widgets/audio_player_widget.dart

- Fecha: 2026-05-07
- Categoria: UX | IA | Auth
- Cambio: Actualizacion de DreamFormScreen (seccion grabacion de audio), DreamDetailScreen (reproductor + transcripcion + bloque analisis IA con boton explicito) y ProfileScreen (campo clave Gemini API con obscure text, guardado en SharedPreferences).
- Impacto: Flujo end-to-end de Sprint 3 completo: grabacion -> subida Storage -> reproduccion -> analisis IA bajo demanda. Clave API nunca expuesta en Firestore.
- Evidencia: lib/features/dreams/presentation/dream_form_screen.dart, lib/features/dreams/presentation/dream_detail_screen.dart, lib/features/profile/presentation/profile_screen.dart, lib/core/config/app_settings.dart

- Fecha: 2026-05-07
- Categoria: Arquitectura | L10n
- Cambio: Extension de archivos de localizacion (app_en.arb, app_es.arb, app_localizations.dart, app_localizations_en.dart, app_localizations_es.dart) con 30 nuevas claves para Sprint 3 (grabadora, reproductor, analisis IA, clave Gemini).
- Impacto: Cobertura completa ES/EN de todas las cadenas del Sprint 3. Sin strings hardcoded en UI nueva.
- Evidencia: lib/l10n/

- Fecha: 2026-05-07
- Categoria: QA
- Cambio: Creacion del checklist de QA formal para Sprint 3 con 55 verificaciones en 10 bloques (entorno, permisos, grabacion, Storage, reproduccion, clave Gemini, analisis IA, seguridad, UI y regresion Sprint 2).
- Impacto: Proceso de validacion objetivo para cierre de Sprint 3. Pendiente ejecucion por Product Owner.
- Evidencia: .github/docs/checklists/qa-sprint-3-checklist.md

- Fecha: 2026-05-07
- Categoria: Agentes | Arquitectura
- Cambio: Eliminacion de documentos duplicados en .github/agents para mantener una sola fuente de verdad en .github/docs y reducir carga de contexto/tokens.
- Impacto: Estructura mas limpia, menor riesgo de inconsistencias entre copias y menor consumo de contexto en agentes.
- Evidencia: .github/agents/README.md, .github/docs/, .github/agents/*.agent.md

- Fecha: 2026-05-09
- Categoria: UX | Arquitectura | IA
- Cambio: Implementacion de Sprint 4 completo — Dashboard de estadisticas, toggle de IA en perfil y mejora de HomeScreen.
- Impacto: Fase 4 del roadmap completada. App funcional end-to-end con analisis de datos, visualizaciones y control de privacidad IA.
- Evidencia:
  - lib/features/dashboard/presentation/dashboard_screen.dart (nuevo) — 4 secciones: resumen numerico, LineChart mood evolution, BarChart suenos/semana, top categorias IA y top tags
  - lib/app/app_routes.dart — ruta /dashboard
  - lib/main.dart — DashboardScreen registrado en routes
  - lib/features/home/presentation/home_screen.dart — boton Dashboard, navegacion directa a DreamFormScreen
  - lib/core/config/app_settings.dart — getAiEnabled / setAiEnabled con SharedPreferences
  - lib/features/profile/presentation/profile_screen.dart — SwitchListTile "Analisis IA activado"
  - lib/features/dreams/presentation/dream_detail_screen.dart — carga _aiEnabled, muestra mensaje cuando IA desactivada
  - lib/l10n/app_en.arb + app_es.arb — 14 nuevas claves para dashboard y toggle IA
  - flutter analyze lib --no-fatal-infos -> EXIT 0

- Fecha: 2026-05-21
- Categoria: L10n | UX
- Cambio: Revision transversal de textos de asistente IA para normalizar marca por idioma: en espanol se muestra "Morfeo" y en ingles "Morpheus" en Dashboard, Home, detalle de sueno, lista de suenos, fallback de analisis y textos legales en ingles.
- Impacto: Consistencia de marca y experiencia multilenguaje; se eliminan referencias fijas que mostraban "Morfeo" cuando la app estaba en ingles.
- Evidencia: lib/features/dashboard/presentation/dashboard_screen.dart, lib/features/home/presentation/home_screen.dart, lib/features/dreams/presentation/dream_detail_screen.dart, lib/features/dreams/presentation/dreams_list_screen.dart, lib/features/dreams/presentation/dream_analysis_step_screen.dart, lib/features/settings/presentation/legal_screen.dart, lib/l10n/app_es.arb; `flutter analyze` (EXIT 0).

- Fecha: 2026-05-21
- Categoria: UX
- Cambio: Redisenada la seccion de "Publicar sueno" en la pantalla de sueno guardado con card dedicada de visibilidad (copy + switch), y bloque de compartir ajustado a layout mas claro y consistente.
- Impacto: Mejor legibilidad y jerarquia de decision de publicacion/compartir sin cambiar la logica funcional de publish ni el flujo de salida al diario.
- Evidencia: lib/features/dreams/presentation/dream_saved_step_screen.dart, comando `flutter analyze lib/features/dreams/presentation/dream_saved_step_screen.dart`

- Fecha: 2026-05-21
- Categoria: Arquitectura | UX
- Cambio: Implementado bus de refresco compartido para el Diario (`DreamsRefreshBus`) y suscripciones/disparadores en lista, guardado de creacion y guardado de edicion.
- Impacto: La pestana Diario se recarga automaticamente tras crear o modificar un sueno, incluso cuando la lista esta viva en `IndexedStack`.
- Evidencia: lib/features/dreams/presentation/dreams_refresh_bus.dart, lib/features/dreams/presentation/dreams_list_screen.dart, lib/features/dreams/presentation/dream_form_screen.dart, lib/features/dreams/presentation/dream_saved_step_screen.dart, comando `flutter analyze lib/features/dreams/presentation/dreams_refresh_bus.dart lib/features/dreams/presentation/dreams_list_screen.dart lib/features/dreams/presentation/dream_form_screen.dart lib/features/dreams/presentation/dream_saved_step_screen.dart`

- Fecha: 2026-05-21
- Categoria: UX | L10n
- Cambio: Migrada la representacion visual de `moodScore` al nuevo modelo de intensidad emocional (Tranquilo, Leve, Moderado, Intenso, Extremo) en Diario, Home, Detalle y formulario, con mapeo centralizado de etiqueta/color y badge dinamico por intensidad.
- Impacto: Consistencia completa de terminologia y colores con el nuevo flujo de captura por intensidad; se elimina la mezcla de etiquetas antiguas (Positivo/Neutral/etc.) en UI.
- Evidencia: lib/shared/utils/intensity_utils.dart, lib/features/dreams/presentation/dreams_list_screen.dart, lib/features/home/presentation/home_screen.dart, lib/features/dreams/presentation/dream_detail_screen.dart, lib/features/dreams/presentation/dream_form_screen.dart, lib/l10n/app_en.arb, lib/l10n/app_es.arb, lib/l10n/app_localizations_en.dart, lib/l10n/app_localizations_es.dart, comando `flutter analyze lib/shared/utils/intensity_utils.dart lib/features/dreams/presentation/dreams_list_screen.dart lib/features/home/presentation/home_screen.dart lib/features/dreams/presentation/dream_detail_screen.dart lib/features/dreams/presentation/dream_form_screen.dart lib/l10n/app_localizations_en.dart lib/l10n/app_localizations_es.dart`

 Fecha: 2026-05-21
 Categoria: UX | Dreams
 Cambio: Eliminacion de "Notas de contexto" en UI del detalle de sueno (metadatos) y retiro de la seccion visual de contexto en el formulario de creacion/edicion (placeholder de etiquetas de contexto).
 Impacto: Flujo de captura y lectura mas limpio, con menos ruido visual en pantallas de suenos.
 Evidencia: lib/features/dreams/presentation/dream_detail_screen.dart, lib/features/dreams/presentation/dream_form_screen.dart, validacion estatica sin errores.
- Impacto: Se elimina `PERMISSION_DENIED` al aceptar solicitudes de seguimiento y se evita el error `FAILED_PRECONDITION` por indice faltante en perfil publico.
- Evidencia: lib/data/repositories/social_repository.dart, firestore.indexes.json
- Evidencia: lib/data/repositories/auth_repository.dart, lib/shared/utils/auth_error_localizer.dart, validacion estatica sin errores en archivos modificados.

- Fecha: 2026-05-20
- Categoria: Auth | UX
- Cambio: Añadido desbloqueo biometrico opcional por dispositivo con estado persistente en ajustes, almacenamiento seguro de credenciales y acceso secundario con huella en login.
- Impacto: Permite iniciar sesion mas rapido en dispositivos compatibles sin exponer la contraseña en texto plano ni alterar el flujo principal de email/password.
- Evidencia: lib/core/config/app_settings.dart, lib/shared/utils/biometric_auth_service.dart, lib/features/settings/presentation/account_security_screen.dart, lib/features/auth/presentation/login_screen.dart, flutter pub get

- Fecha: 2026-05-20
- Categoria: Auth | Arquitectura | UX
- Cambio: Hotfix de compilacion tras integrar biometria: reintroducidos imports faltantes de AppSettings/BiometricAuthService/firebase_auth y reparado el bloque duplicado del Scaffold en DreamFormScreen, sustituyendo ademas el campo obsoleto `dream.date` por `dream.dreamDate`.
- Impacto: Recuperada la compilacion del login, ajustes y formulario de suenos; el flujo biometrico queda integrado sin romper la pantalla de creacion/edicion.
- Evidencia: lib/features/auth/presentation/login_screen.dart, lib/features/settings/presentation/account_security_screen.dart, lib/features/dreams/presentation/dream_form_screen.dart, get_errors sin errores en los archivos modificados.

- Fecha: 2026-05-20
- Categoria: Auth | Firestore | UX
- Cambio: Endurecido el flujo de eliminacion de cuenta con reautenticacion por contrasena en repositorio (`deleteAccountWithPassword`) y limpieza transaccional de `users/{uid}` + reserva `usernames/{displayNameLower}`. Redisenado el confirmador de eliminacion en Cuenta y seguridad para solicitar contrasena con modal visual glass/destructivo.
- Impacto: Se evita que queden usernames bloqueados tras borrar una cuenta y se mejora seguridad/claridad del flujo de accion irreversible.

- Fecha: 2026-05-20
- Categoria: UX | L10n
- Cambio: Segunda pasada de localizacion en pantallas clave para eliminar hardcodes de UI en flujo de analisis/guardado de suenos, cuenta y seguridad, y solicitudes de seguimiento; se incorporaron nuevas claves ES/EN y regeneracion de localizations.
- Impacto: Cobertura bilingue mas consistente en flujos de alto uso y reduccion de riesgo de regresiones por textos embebidos.
- Evidencia: lib/features/dreams/presentation/dream_analysis_step_screen.dart, lib/features/dreams/presentation/dream_saved_step_screen.dart, lib/features/settings/presentation/account_security_screen.dart, lib/features/social/presentation/follow_requests_screen.dart, lib/l10n/app_es.arb, lib/l10n/app_en.arb, flutter gen-l10n

- Fecha: 2026-05-20
- Categoria: UX | L10n | Validacion
- Cambio: Correccion transversal del cambio de idioma en pantallas post-auth (main shell, ajustes, diario, dashboard, perfil y editar perfil) reemplazando strings hardcodeados por claves `AppLocalizations`, activando cambio real de locale desde ajustes y anadiendo nuevas claves EN/ES. Ajustada validacion de nombre para permitir Unicode latino (incluyendo n con tilde y vocales acentuadas) con filtrado de caracteres no permitidos.
- Impacto: El selector ES/EN se refleja en gran parte de la app fuera de auth y se elimina friccion al introducir nombres con caracteres latinos comunes sin degradar validaciones basicas.
- Evidencia: lib/app/main_shell.dart, lib/features/settings/presentation/settings_screen.dart, lib/features/dreams/presentation/dreams_list_screen.dart, lib/features/dreams/presentation/dream_form_screen.dart, lib/features/dashboard/presentation/dashboard_screen.dart, lib/features/profile/presentation/profile_screen.dart, lib/features/settings/presentation/edit_profile_screen.dart, lib/shared/utils/validators_formatters.dart, lib/l10n/app_es.arb, lib/l10n/app_en.arb, flutter gen-l10n, flutter analyze
- Evidencia: lib/data/repositories/auth_repository.dart, lib/features/settings/presentation/account_security_screen.dart, validacion estatica sin errores en archivos modificados.

- Fecha: 2026-05-20
- Categoria: UX | Audio | Arquitectura
- Cambio: Redisenado el manejo de audio en el formulario de suenos para flujo multi-clip (maximo 3), inicio de grabacion inmediato al tocar anadir, feedback explicito al superar limite y control claro de detener durante grabacion.
- Impacto: Mejora de claridad en captura por voz y soporte consistente de multiples audios adjuntos con reproduccion/pausa y eliminacion por clip sin romper compatibilidad existente.
- Evidencia: lib/features/dreams/presentation/dream_form_screen.dart, lib/shared/widgets/audio_recorder_widget.dart, validacion estatica sin errores en archivos modificados.

- Fecha: 2026-05-20
- Categoria: UX | IA | Firestore | Arquitectura

- Fecha: 2026-05-20
- Categoria: QA | Infraestructura | Flutter
- Cambio: Diagnostico del incidente `Error initializing DevFS` y `Lost connection to device` tras `flutter run` en entorno Windows. Se confirma despliegue correcto de indices Firestore y se identifica bloqueo local por falta de soporte de symlinks (Developer Mode desactivado), ademas de dependencia de `adb` fuera de PATH.
- Impacto: Se evita atribuir el fallo a Firebase/Firestore cuando la causa raiz es de entorno local de desarrollo; se define ruta de recuperacion reproducible para volver a ejecutar la app en emulador.
- Evidencia: comando `firebase deploy --only firestore:indexes` exitoso, `flutter pub get` con error de symlinks, `flutter doctor -v`, `adb devices -l`.

- Fecha: 2026-05-20
- Categoria: Firestore | Social | Seguridad
- Cambio: Ajustadas reglas de `followRequests` para permitir `get/delete` tanto con esquema actual (`requesterId/targetId`) como con documentos legacy (`senderId/receiverId`) y fallback por patron de `docId` (`{requesterId}_{targetId}`).
- Impacto: Evita `PERMISSION_DENIED` al aceptar/declinar solicitudes antiguas y mantiene el principio de participante autorizado en el documento.
- Evidencia: firestore.rules (match `/followRequests/{docId}`), validacion estatica sin errores.
- Cambio: Ajustada la regla de guardado de suenos a "titulo + (descripcion o audio)", permitiendo texto vacio cuando hay audio. Endurecido el flujo de Morfeo para bloquear el avance a compartir/publicar cuando falle transcripcion/analisis o la transcripcion sea insuficiente, mostrando popup informativo y manteniendo al usuario en la pantalla de analisis.
- Impacto: Se habilita el caso de uso "solo titulo + audio" y se evita publicar resultados de IA poco fiables o fallidos. El usuario conserva la opcion de guardar sin analisis desde la misma pantalla.
- Evidencia: lib/features/dreams/presentation/dream_form_screen.dart, lib/features/dreams/presentation/dream_analysis_step_screen.dart, lib/data/repositories/dream_repository.dart, firestore.rules, get_errors sin errores en archivos modificados.

- Fecha: 2026-05-20
- Categoria: UX | Audio
- Cambio: Hotfix del input de grabacion en formulario de suenos: flujo explicito de Iniciar grabacion -> Detener y adjuntar, con estados de procesamiento separados para inicio/finalizacion y boton de cancelacion estable.
- Impacto: Se elimina el comportamiento ambiguo al detener grabacion y se mejora la fiabilidad tactil para cerrar la toma y adjuntarla al formulario.
- Evidencia: lib/shared/widgets/audio_recorder_widget.dart, lib/features/dreams/presentation/dream_form_screen.dart, get_errors sin errores en archivos modificados.

- Fecha: 2026-05-20
- Categoria: UX | IA
- Cambio: Mejora visual y de comunicacion en el paso "Analizar sueno": popup de advertencia con orbe de Morfeo y etiqueta visual, recuadro informativo de Morfeo en la tarjeta de analisis, y mensajes de error adaptados para indicar explicitamente posibles causas en audio (no se escucha bien o informacion insuficiente).
- Impacto: Mayor claridad para el usuario sobre por que Morfeo puede fallar y como proceder (reintentar con mejor audio o guardar sin analisis), reduciendo confusion en el flujo.
- Evidencia: lib/features/dreams/presentation/dream_analysis_step_screen.dart, get_errors sin errores en archivo modificado.

- Fecha: 2026-05-21
- Categoria: UX | IA
- Cambio: Rediseno visual de la pantalla intermedia de resultado de Morfeo con hero destacado (orbe + contexto), jerarquia de tarjetas por seccion, pildoras/chips mejoradas para entidades y CTA primario fijo al pie para continuar a publicacion.
- Impacto: Pantalla de resultado mas clara y atractiva sin alterar el flujo post-analisis; se mantienen visibles todos los campos de IA (sentimiento, categoria, emociones, personajes, lugares, temas, nota psicologica y resumen).
- Evidencia: lib/features/dreams/presentation/dream_morfeo_result_screen.dart, comando `flutter analyze lib/features/dreams/presentation/dream_morfeo_result_screen.dart` (sin issues).

- Fecha: 2026-05-20
- Categoria: UX | IA
- Cambio: Rediseno de jerarquia visual en los pasos "Analizar sueno" y "Compartir": Morfeo ampliado de forma significativa durante carga de analisis, tarjeta de opciones de analisis expandida para aprovechar la altura completa y aumento de escala en elementos de compartir/publicar con orbe principal mas protagonista.
- Impacto: Mayor presencia de Morfeo en momentos clave y mejor uso del espacio vertical en ambos pasos del wizard, con acciones mas visibles y legibles.
- Evidencia: lib/features/dreams/presentation/dream_analysis_step_screen.dart, lib/features/dreams/presentation/dream_saved_step_screen.dart, get_errors sin errores en archivos modificados.

- Fecha: 2026-05-20
- Categoria: UX | Audio | Arquitectura
- Cambio: Endurecido el flujo "Guardar sin analisis" en el paso de analisis: si falla la subida de audios se bloquea el guardado con popup explicito; si tras la subida no queda texto ni audio valido se muestra error especifico y no se crea el sueno. Ademas, la pantalla de carga de este flujo deja de mostrar a Morfeo y usa iconografia neutra de guardado.
- Impacto: Evita fallos silenciosos al guardar suenos solo con audio y elimina confusion visual al no asociar Morfeo al guardado sin analisis.
- Evidencia: lib/features/dreams/presentation/dream_analysis_step_screen.dart, get_errors sin errores en archivo modificado.

- Fecha: 2026-05-20
- Categoria: Firestore | Social | Seguridad
- Cambio: Ajuste de reglas en `follows` para permitir la aceptacion de solicitudes por parte del usuario objetivo solo cuando existe `followRequests/{followerId_followingId}` pendiente y consistente con `requesterId/targetId`, manteniendo borrado restringido al `follower`.
- Impacto: Corrige `PERMISSION_DENIED` al aceptar solicitudes de seguimiento sin abrir escrituras arbitrarias de relaciones de seguimiento.
- Evidencia: firestore.rules (match `/follows/{docId}`), validacion por inspeccion del flujo `acceptFollowRequest` en `lib/data/repositories/social_repository.dart`.

- Fecha: 2026-05-21
- Categoria: UX | IA | L10n | Functions
- Cambio: Se inserta un nuevo paso intermedio en el wizard de creacion para mostrar el resultado completo de Morfeo antes de la pantalla de publicacion. Se actualiza `analyzeDream` en Cloud Functions para soportar idioma de respuesta EN/ES segun locale enviado por cliente, manteniendo etiquetas de parsing estables.
- Impacto: El usuario puede revisar todos los campos del analisis (sentiment, category, emotions, characters, places, themes, psychological note y summary) antes de publicar, y recibe resultados en ingles o espanol segun idioma activo en la app.
- Evidencia: lib/features/dreams/presentation/dream_morfeo_result_screen.dart, lib/features/dreams/presentation/dream_analysis_step_screen.dart, functions/src/index.ts, lib/l10n/app_es.arb, lib/l10n/app_en.arb, flutter gen-l10n, flutter analyze

