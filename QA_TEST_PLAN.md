# 📋 Hypnos Dream Journal — Plan de Pruebas QA

> **Cómo usar este documento**: Para cada caso, sigue los pasos y compara el resultado real con el esperado.  
> Marca ✅ **PASA**, ❌ **FALLA** o ⚠️ **PARCIAL** en la columna Resultado.  
> Columna **Plataforma** indica si aplica a Android (A), iOS (I) o ambos (A/I).

---

## F01 — Registro de cuenta

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F01-01 | Abrir app → pantalla de bienvenida → pulsar **"Comenzar"** / **"Crear cuenta"** | Se abre el formulario de registro con campos Nombre, Correo, Contraseña y Confirmar contraseña |✅| A/I |
| F01-02 | Dejar todos los campos vacíos → pulsar **"Crear cuenta"** | Se muestran mensajes de error bajo cada campo obligatorio; no se navega |✅| A/I |
| F01-03 | Introducir nombre de 1 carácter | Error: nombre demasiado corto |✅| A/I |
| F01-04 | Introducir un correo sin arroba (`user.com`) | Error: correo inválido |✅| A/I |
| F01-05 | Introducir contraseña de 7 caracteres (`Abc1234`) | Error: contraseña demasiado corta (mínimo 8) |✅| A/I |
| F01-06 | Contraseña sin mayúscula (`abcdef12`) | Error: debe contener mayúscula |✅| A/I |
| F01-07 | Contraseña sin minúscula (`ABCDEF12`) | Error: debe contener minúscula |✅| A/I |
| F01-08 | Contraseña sin dígito (`Abcdefgh`) | Error: debe contener número |✅| A/I |
| F01-09 | Contraseña y confirmación distintas | Error: las contraseñas no coinciden |✅| A/I |
| F01-10 | Rellenar todos los campos correctamente → pulsar **"Crear cuenta"** | Cuenta creada; se navega a la pantalla principal (Home) |✅| A/I |
| F01-11 | Intentar registrar con un correo ya existente | Error visible: "El correo ya está en uso" o similar |✅| A/I |
| F01-12 | Pulsar **"Continuar con Google"** | Se abre el selector de cuenta Google; al elegir, se navega al Home |✅| A |
| F01-13 | Pulsar **"Continuar con Apple"** | Se abre el diálogo de Apple ID; al completar, se navega al Home |✅| I |

---

## F02 — Inicio de sesión

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F02-01 | Pantalla de bienvenida → **"Iniciar sesión"** | Se abre la pantalla de login |✅| A/I |
| F02-02 | Dejar ambos campos vacíos → **"Entrar"** | Errores de campo obligatorio; sin navegación |✅| A/I |
| F02-03 | Correo válido + contraseña incorrecta | Error: credenciales incorrectas |✅| A/I |
| F02-04 | Correo no existente | Error de autenticación; no navega |✅| A/I |
| F02-05 | Credenciales correctas | Navega al Home |✅| A/I |
| F02-06 | Pulsar **"¿Olvidaste tu contraseña?"** → introducir correo → enviar | Toast/mensaje: "Correo de recuperación enviado" |✅| A/I |
| F02-07 | Pulsar **"¿No tienes cuenta? Regístrate"** | Navega a la pantalla de registro |✅| A/I |
| F02-08 | Activar biometría en ajustes → cerrar sesión → abrir app de nuevo | Se pide autenticación biométrica y, si se acepta, entra directamente |✅| A/I |

---

## F03 — Formulario de creación de sueño

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F03-01 | Home → botón **"+"** o **"Nuevo sueño"** | Se abre el formulario vacío con modo creación |✅| A/I |
| F03-02 | Pulsar **"Guardar"** / **"CUÉNTALO"** con todos los campos vacíos | Error en el campo Título; campo descripción requerido |✅| A/I |
| F03-03 | Rellenar solo el título y pulsar guardar | Error en el campo descripción |✅| A/I |
| F03-04 | Rellenar título + descripción → guardar | Sueño creado; regresa a Home y aparece en la lista |✅| A/I |
| F03-05 | Pulsar el selector de fecha | Se abre el date picker; elegir una fecha distinta a hoy | | A/I |
| F03-06 | Mover el deslizador de estado de ánimo | El valor numérico del ánimo se actualiza en pantalla |✅| A/I |
| F03-07 | Pulsar **"Agregar audio"** → grabar 3 segundos → detener | El audio aparece adjunto al formulario |✅| A/I |
| F03-08 | Crear sueño solo con audio (sin texto) → guardar | Sueño guardado con el audio; descripción vacía permitida |✅| A/I |
| F03-09 | Marcar la opción de **"Publicar"** o activar visibilidad pública → guardar | Sueño creado y visible en el feed público |✅| A/I |
| F03-10 | Marcar la opción **"Solo seguidores"** → guardar | Solo usuarios que te siguen pueden ver el sueño |✅| A/I |
| F03-11 | Pulsar **"Analizar con Morfeo"** (si está disponible) | Se muestra un indicador de carga; tras unos segundos aparecen categoría, resumen y etiquetas IA |✅| A/I |

---

## F04 — Edición de sueño existente ⚠️

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F04-01 | Desde la lista de sueños → pulsar un sueño → icono **editar** | Se abre el formulario en modo edición con los datos pre-rellenados |✅| A/I |
| F04-02 | Modificar el título → pulsar **"Guardar"** en el AppBar | El sueño se actualiza; la lista muestra el nuevo título |✅| A/I |
| F04-03 | Borrar completamente el título → pulsar **"Guardar"** | Error: título obligatorio |✅| A/I |
| F04-04 | En modo edición, borrar la descripción y guardar | Se guarda correctamente (descripción no es obligatoria al editar) |✅| A/I |
| F04-05 | Cambiar la fecha del sueño | La nueva fecha se guarda correctamente |✅| A/I |
| F04-06 | Cambiar el estado de ánimo | Se guarda el nuevo valor numérico |✅| A/I |
| F04-07 | Si el sueño tiene análisis IA, abrir modo edición | Se muestra la sección `_AiTagsPreview` con la categoría, resumen y etiquetas reales |✅| A/I |
| F04-08 | Si el sueño NO tiene análisis IA, abrir modo edición | No se muestra ningún placeholder ni sección IA |✅| A/I |
| F04-09 | Cambiar visibilidad de privado a público en edición → guardar | El sueño ahora aparece en `publicDreams`; el disclaimer muestra el texto correcto |✅| A/I |

---

## F05 — Eliminación de sueño ✅

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F05-01 | Sueño → menú opciones → **"Eliminar"** | Se muestra diálogo de confirmación |✅| A/I |
| F05-02 | En el diálogo, pulsar **"Cancelar"** | El sueño sigue en la lista; no se elimina |✅| A/I |
| F05-03 | En el diálogo, confirmar eliminación | El sueño desaparece de la lista |✅| A/I |
| F05-04 | Eliminar un sueño publicado | Desaparece también de `publicDreams` / feed público |✅| A/I |

---

## F06 — Feed e inicio

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F06-01 | Abrir la pestaña **Home** | Se muestra el feed con sueños propios y de usuarios que sigo |✅| A/I |
| F06-02 | Hacer scroll hasta el final del feed | Se cargan más sueños (paginación) o se muestra "Sin más sueños" |✅| A/I |
| F06-03 | Pulsar un sueño del feed | Se abre el detalle del sueño con título, descripción, etiquetas, fecha |✅| A/I |
| F06-04 | Dar **like** a un sueño del feed | El contador de likes aumenta en 1; el icono cambia a estado activo |✅| A/I |
| F06-05 | Quitar el like | El contador baja en 1; icono vuelve a inactivo |✅| A/I |
| F06-08 | Pulsar en el avatar/nombre del autor de un sueño | Navega al perfil público del autor |✅| A/I |

---

## F07 — Buscador de usuarios

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F07-01 | Pestaña **Explorar** o icono de búsqueda en Home → escribir un nombre existente | Aparece el usuario en los resultados con avatar y nombre |✅| A/I |
| F07-02 | Buscar un nombre que no existe | Se muestra estado vacío: "Sin resultados" |✅| A/I |
| F07-03 | Buscar con menos de 2 caracteres | No se lanza búsqueda o se muestran instrucciones |✅| A/I |
| F07-04 | Pulsar un resultado de búsqueda | Navega al perfil público del usuario |✅| A/I |
| F07-05 | Borrar el texto de búsqueda | Los resultados desaparecen |✅| A/I |

---

## F08 — Perfil público y seguimiento

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F08-01 | Abrir perfil de un usuario que no sigo | Botón muestra **"Seguir"** (relleno, color acento) |✅| A/I |
| F08-02 | Pulsar **"Seguir"** | Botón cambia a **"Solicitado"** (gris, sin relleno); se crea doc en `followRequests` |✅| A/I |
| F08-03 | Pulsar **"Solicitado"** | Botón vuelve a **"Seguir"**; se cancela la solicitud |✅| A/I |
| F08-04 | El dueño del perfil acepta la solicitud → volver al perfil | Botón cambia a **"Siguiendo"** |✅| A/I |
| F08-05 | Pulsar **"Siguiendo"** | Se deja de seguir; botón vuelve a **"Seguir"** |✅| A/I |
| F08-06 | Desde el perfil público, ver la lista de sueños públicos | Se muestran solo los sueños publicados del usuario |✅| A/I |
| F08-07 | Contadores de seguidores/seguidos visibles | Los números coinciden con los valores reales |✅| A/I |

---

## F09 — Solicitudes de seguimiento

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F09-01 | Ir a **Mi perfil** → icono de personas en la barra superior | Navega a la pantalla "Solicitudes de seguimiento" |✅| A/I |
| F09-02 | Sin solicitudes pendientes | Se muestra estado vacío: "Sin solicitudes pendientes" |✅| A/I |
| F09-03 | Con al menos una solicitud entrante | Se muestra la lista con avatar, nombre del solicitante y botones Aceptar/Rechazar |✅| A/I |
| F09-04 | Pulsar **"Aceptar"** en una solicitud | La solicitud desaparece de la lista; el solicitante aparece en seguidores |✅| A/I |
| F09-05 | Pulsar **"Rechazar"** en una solicitud | La solicitud desaparece de la lista; el contador de seguidores no cambia |✅| A/I |
| F09-06 | Badge numérico en el icono del perfil | Muestra el número de solicitudes pendientes; desaparece cuando llega a 0 |✅| A/I |
| F09-07 | Badge con más de 9 solicitudes | Muestra **"9+"** en el badge | | A/I |
| F09-08 | Pulsar en el avatar/nombre de un solicitante dentro de la lista | Navega al perfil público del solicitante |✅| A/I |

---

## F10 — Mi perfil

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F10-01 | Ir a la pestaña **Perfil** | Se muestra nombre, foto, bio, contadores de sueños/seguidores/seguidos |✅| A/I |
| F10-02 | Pestaña de sueños del perfil | Lista solo los sueños propios (incluyendo privados) |✅| A/I |
| F10-03 | Badge de solicitudes actualizado en tiempo real | Al recibir nueva solicitud, el badge aumenta sin reiniciar la app |✅| A/I |

---

## F11 — Ajustes: Editar perfil

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F11-01 | Ajustes → **"Editar perfil"** | Se abre el formulario con nombre y foto actuales |✅| A/I |
| F11-02 | Cambiar el nombre y guardar | El perfil se actualiza en Home y Perfil |✅| A/I |
| F11-03 | Pulsar en la foto → seleccionar imagen de galería | La nueva foto aparece en el formulario |✅| A/I |
| F11-04 | Guardar con la nueva foto | La foto se actualiza en el perfil |✅| A/I |
| F11-05 | Dejar el nombre vacío → guardar | Error de validación |✅| A/I |

---

## F12 — Ajustes: Cuenta y seguridad

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F12-01 | Ajustes → **"Cuenta y seguridad"** | Se muestran opciones de cambio de contraseña, biometría y eliminar cuenta |✅| A/I |
| F12-02 | Activar biometría (si no estaba activa) | Se pide autenticación biométrica; al aceptar, queda activada |✅| A/I |
| F12-03 | Desactivar biometría | Se desactiva sin pedir autenticación |✅| A/I |
| F12-04 | Pulsar **"Eliminar cuenta"** | Se muestra un diálogo de confirmación con aviso de pérdida de datos |✅| A/I |
| F12-05 | Confirmar eliminación de cuenta | La sesión se cierra y vuelve a la pantalla de bienvenida |✅| A/I |
| F12-06 | Cerrar sesión | Vuelve a la pantalla de bienvenida |✅| A/I |

---

## F13 — Ajustes: Notificaciones

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F13-01 | Ajustes → **"Notificaciones"** | Se muestran los toggles de notificación por categorías |✅| A/I |
| F13-02 | Desactivar **"Recordatorio diario"** | El switch queda en OFF; no se reciben notificaciones de recordatorio |✅| A/I |
| F13-03 | Desactivar **"Nuevos seguidores"** | Switch en OFF; sin notificación al recibir un nuevo seguidor |✅| A/I |
| F13-04 | Desactivar **"Solicitudes de seguimiento"** | Sin notificación al recibir solicitudes |✅| A/I |
| F13-05 | Desactivar **"Sueños de seguidos"** | Switch en OFF; las notificaciones push de nuevos sueños no llegan |✅| A/I |
| F13-06 | Volver a activar **"Sueños de seguidos"** | Switch en ON; las notificaciones vuelven a llegar |✅| A/I |
| F13-07 | Los cambios se persisten | Cerrar y reabrir Ajustes → Notificaciones: los mismos estados |✅| A/I |

---

## F14 — Notificaciones push (FCM)

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F14-01 | Primera vez que se abre la app con la cuenta activa | Se solicita permiso de notificaciones (solo iOS); el token FCM se guarda en Firestore bajo `users/{uid}.fcmToken` |✅| I |
| F14-02 | Usuario A sigue a usuario B (solicitud aceptada) → B publica un sueño con visibilidad "público" | A recibe una notificación push con el texto: "B publicó un sueño" |✅| A/I |
| F14-03 | Usuario A tiene **"Sueños de seguidos"** desactivado → B publica | A NO recibe la notificación |✅| A/I |
| F14-04 | Pulsar la notificación push | La app abre o navega al sueño publicado / perfil del autor |✅| A/I |
| F14-05 | App en primer plano cuando llega la notificación | Se muestra banner o snackbar dentro de la app |✅| A/I |

---

## F15 — Ajustes: Idioma

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F15-01 | Ajustes → **"Idioma"** | Se abre un selector de idioma con Español e English |✅| A/I |
| F15-02 | Seleccionar **English** | Toda la UI cambia al inglés de forma inmediata |❌| A/I |
| F15-03 | El idioma persiste | Cerrar y reabrir la app → sigue en inglés |❌| A/I |
| F15-04 | Seleccionar **Español** | Vuelve al español |❌| A/I |

---

## F16 — Legal: Política de privacidad y Términos

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F16-01 | Ajustes → **"Política de privacidad"** (app en español) | Se abre la pantalla con contenido en español; se lee "Última actualización: 20 de mayo de 2026" |✅| A/I |
| F16-02 | Scroll por todas las secciones | Se ven todas las 11 secciones numeradas; el texto es legible y coherente con el estilo de la app |✅| A/I |
| F16-03 | Botón de retroceso | Vuelve a la pantalla de Ajustes |✅| A/I |
| F16-04 | Cambiar idioma a English → Ajustes → **"Política de privacidad"** | El contenido aparece en inglés (Privacy Policy) |✅| A/I |
| F16-05 | Ajustes → **"Términos y condiciones"** (español) | Se abre con las 12 secciones en español |✅| A/I |
| F16-06 | Ajustes → **"Términos y condiciones"** (english) | El contenido aparece en inglés (Terms & Conditions) |✅| A/I |

---

## F17 — Análisis IA (Morfeo)

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F17-01 | Crear sueño con texto → guardar → esperar análisis automático (o pulsarlo manualmente) | Aparece la sección Morfeo con: categoría, resumen y etiquetas semánticas |✅| A/I |
| F17-02 | Abrir en modo edición un sueño con análisis | Se muestra `_AiTagsPreview` con la categoría, resumen y etiquetas del análisis existente |✅| A/I |
| F17-03 | Abrir en modo edición un sueño sin análisis | La sección de IA no aparece (ni placeholder ni preview) |✅| A/I |
| F17-04 | Las etiquetas mood: no aparecen en la vista pública como etiquetas | Las etiquetas que empiezan por `mood:` se filtran; solo se muestran etiquetas semánticas |✅| A/I |
| F17-05 | App en español → analizar sueño real (por ejemplo Sueño 1 o 7) | El resumen y la nota psicológica aparecen en español, no en inglés |✅| A/I |
| F17-06 | App en English → analizar el mismo sueño | El resumen y la nota psicológica aparecen en inglés |✅| A/I |
| F17-07 | Analizar un texto incoherente (por ejemplo 100 caracteres de `aaaa...`) | Morfeo muestra una lectura de baja calidad explícita, pero en el idioma de la app; no devuelve una pantalla vacía |✅| A/I |
| F17-08 | Analizar sueños con temas distintos (agua, caída, persecución, vuelo, dientes, examen) | El resumen y la nota cambian según el patrón del sueño, no se repite el mismo texto genérico |✅| A/I |

---

## F18 — Audio

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F18-01 | Formulario de creación → pulsar **grabar** → hablar → detener | Se muestra el audio grabado con duración |✅| A/I |
| F18-02 | Pulsar el botón de **reproducir** el audio | El audio se reproduce; se muestra el progreso |✅| A/I |
| F18-03 | Pulsar **eliminar audio** | El audio desaparece del formulario |✅| A/I |
| F18-04 | Guardar sueño solo con audio (sin texto) | Se guarda correctamente sin error de descripción |✅| A/I |
| F18-05 | Ver el sueño después de guardado | El audio está disponible para reproducir en la pantalla de detalle |✅| A/I |

---

## F19 — Dashboard / Estadísticas

| ID | Pasos | Resultado esperado | Resultado | Plat. |
|----|-------|--------------------|-----------|-------|
| F19-01 | Navegar a la pestaña **Dashboard** | Se muestran estadísticas: total de sueños, promedio de ánimo, distribución de emociones |✅| A/I |
| F19-02 | Sin sueños registrados | Se muestra estado vacío con mensaje motivacional |✅| A/I |
| F19-03 | Con varios sueños | Los gráficos reflejan los datos reales del usuario |✅| A/I |

---

## Notas adicionales

- **Conectividad**: Prueba F03, F07, F08, F09 también con conexión intermitente para validar manejo de errores.
- **Cuenta nueva**: Algunos tests (F09-02, F06-01 sin seguidos) requieren una cuenta sin actividad previa.
- **Dos dispositivos**: Los tests F09-03 al F09-05 y F14-02 requieren dos cuentas / dispositivos.
- **Cloud Functions**: F17-01 y F14-02 dependen de funciones desplegadas en Firebase. Asegúrate de haber ejecutado `firebase deploy --only functions` antes de probarlos.
