# QA Checklist — Sprint 3: Multimedia e IA

Fecha de creación: 2026-05-07  
Fase: 3 — Multimedia e IA  
Sprint: 3  
Versión app: 1.0.0+1  

## Objetivo de validación
Verificar que el flujo completo de grabación de audio, reproducción, subida a Firebase Storage y análisis con Gemini IA funciona de forma estable y segura en entorno de desarrollo.

## Criterio de aceptación global
- Todos los bloques marcados como **[Obligatorio]** deben pasar sin error.
- Los bloques **[Opcional]** son deseables pero no bloquean el cierre del sprint.
- Resultado final: Aprobado | Aprobado con ajustes | Rechazado.

---

## Bloque 1: Entorno y compilación

| # | Verificación | Resultado | Notas |
|---|---|---|---|
| 1.1 | `flutter analyze lib` termina sin errores (solo infos pre-existentes permitidos) | ⬜ | |
| 1.2 | App compila y arranca en Android (emulador o dispositivo físico) | ⬜ | |
| 1.3 | App compila y arranca en iOS (simulador o dispositivo físico) | ⬜ | |
| 1.4 | Firebase se inicializa correctamente (sin crash en bootstrap) | ⬜ | |
| 1.5 | No hay regresiones visibles en flujos de Sprint 2 (login, CRUD de sueños, perfil) | ⬜ | |

---

## Bloque 2: Permisos de micrófono

| # | Verificación | Resultado | Notas |
|---|---|---|---|
| 2.1 | Al pulsar "Iniciar grabación" por primera vez, se solicita permiso de micrófono | ⬜ | |
| 2.2 | Si el usuario deniega el permiso, se muestra mensaje de error (no crash) | ⬜ | |
| 2.3 | Si el usuario concede el permiso, la grabación inicia correctamente | ⬜ | |
| 2.4 | En Android: el permiso `RECORD_AUDIO` aparece en el manifest correctamente | ⬜ | Verificar `AndroidManifest.xml` |
| 2.5 | En iOS: el permiso `NSMicrophoneUsageDescription` está definido en `Info.plist` | ⬜ | Verificar string descriptivo |

---

## Bloque 3: Grabación de audio (AudioRecorderWidget)

| # | Verificación | Resultado | Notas |
|---|---|---|---|
| 3.1 | El botón "Iniciar grabación" aparece en el formulario de nuevo sueño | ⬜ | |
| 3.2 | Al iniciar la grabación, aparece el punto rojo pulsante y el cronómetro | ⬜ | |
| 3.3 | El cronómetro avanza segundo a segundo correctamente | ⬜ | |
| 3.4 | Al pulsar "Detener grabación", el estado cambia a "Audio grabado" | ⬜ | |
| 3.5 | El botón "Eliminar" en estado grabado borra la grabación y vuelve al estado inicial | ⬜ | |
| 3.6 | No se puede crear más de una grabación activa simultáneamente | ⬜ | |
| 3.7 | Si se abandona el formulario con grabación activa, la grabación se cancela sin leak | ⬜ | |

---

## Bloque 4: Subida de audio a Firebase Storage

| # | Verificación | Resultado | Notas |
|---|---|---|---|
| 4.1 | Al guardar un sueño con grabación, el campo `hasAudio: true` aparece en Firestore | ⬜ | Verificar en Firebase Console |
| 4.2 | El campo `audioPath` contiene una URL de descarga válida de Firebase Storage | ⬜ | |
| 4.3 | El archivo de audio existe en Storage bajo `users/{uid}/dreams/{dreamId}/audio.m4a` | ⬜ | |
| 4.4 | Solo el usuario propietario puede leer su propio audio (reglas de Storage) | ⬜ | Intentar acceso con otro uid |
| 4.5 | Si la subida falla, el sueño se guarda igualmente (texto/mood) sin crash | ⬜ | Simular sin conexión |
| 4.6 | El archivo temporal local se borra tras la subida exitosa | ⬜ | |

---

## Bloque 5: Reproducción de audio (AudioPlayerWidget)

| # | Verificación | Resultado | Notas |
|---|---|---|---|
| 5.1 | En el detalle de un sueño con audio, aparece el reproductor con botón Play | ⬜ | |
| 5.2 | Al pulsar Play, el audio se reproduce desde la URL remota de Storage | ⬜ | |
| 5.3 | El slider avanza en tiempo real mientras reproduce | ⬜ | |
| 5.4 | El contador de posición y duración se muestran correctamente | ⬜ | |
| 5.5 | Al pulsar Pause, la reproducción se detiene sin crash | ⬜ | |
| 5.6 | Al arrastrar el slider, la reproducción salta al nuevo punto | ⬜ | |
| 5.7 | Al terminar la reproducción, el slider vuelve al inicio | ⬜ | |
| 5.8 | En sueños sin audio, el reproductor no aparece | ⬜ | |

---

## Bloque 6: Clave API de Gemini (Perfil)

| # | Verificación | Resultado | Notas |
|---|---|---|---|
| 6.1 | En la pantalla de perfil, existe un campo "Clave API de Gemini" | ⬜ | |
| 6.2 | El campo muestra texto oculto por defecto (obscureText) | ⬜ | |
| 6.3 | El botón del ojo alterna visibilidad del texto | ⬜ | |
| 6.4 | Al guardar una clave, se muestra SnackBar de confirmación | ⬜ | |
| 6.5 | Al reiniciar la app, la clave guardada persiste (SharedPreferences) | ⬜ | |
| 6.6 | Al borrar la clave y guardar, se muestra SnackBar de "eliminada" | ⬜ | |
| 6.7 | La clave NO se guarda en Firestore (solo en SharedPreferences local) | ⬜ | Verificar que no aparece en Firebase Console |

---

## Bloque 7: Análisis IA con Gemini (DreamDetailScreen)

| # | Verificación | Resultado | Notas |
|---|---|---|---|
| 7.1 | En el detalle de un sueño, existe el bloque "Análisis IA" con botón | ⬜ | |
| 7.2 | Sin clave API guardada, el botón muestra mensaje orientativo (no crash) | ⬜ | |
| 7.3 | Con clave API válida, al pulsar el botón aparece spinner "Analizando..." | ⬜ | Requiere clave Gemini real |
| 7.4 | El análisis devuelve: sentimiento, categoría, emociones, personajes, lugares, temas | ⬜ | |
| 7.5 | La nota psicológica se muestra en el bloque de análisis | ⬜ | |
| 7.6 | Los campos `aiCategory` y `aiSummary` se actualizan en Firestore tras el análisis | ⬜ | Verificar en Firebase Console |
| 7.7 | Con clave API inválida, se muestra error amigable (no crash) | ⬜ | |
| 7.8 | El análisis funciona tanto en español como en inglés (responde en el idioma del texto) | ⬜ | |

---

## Bloque 8: Seguridad y privacidad

| # | Verificación | Resultado | Notas |
|---|---|---|---|
| 8.1 | Las reglas de Firestore siguen impidiendo acceso entre usuarios | ⬜ | |
| 8.2 | Las reglas de Storage siguen impidiendo acceso a audios de otros usuarios | ⬜ | |
| 8.3 | La clave Gemini nunca viaja a Firestore ni a Storage | ⬜ | |
| 8.4 | No se registran datos sensibles en logs de producción | ⬜ | |
| 8.5 | El switch de AI (aiEnabled en perfil de usuario) es respetado antes de llamar a Gemini | ⬜ | **[Opcional]** — Sprint 3 básico no lo bloquea |

---

## Bloque 9: UI y accesibilidad

| # | Verificación | Resultado | Notas |
|---|---|---|---|
| 9.1 | El grabador de audio se adapta correctamente en pantalla pequeña (360dp) | ⬜ | |
| 9.2 | El reproductor de audio se adapta correctamente en pantalla grande (tablet) | ⬜ | |
| 9.3 | El bloque de análisis IA se renderiza sin overflow en textos largos | ⬜ | |
| 9.4 | La sección de clave API en perfil tiene contraste suficiente en tema oscuro | ⬜ | |
| 9.5 | En modo idioma inglés, todos los strings nuevos están traducidos | ⬜ | |
| 9.6 | En modo idioma español, todos los strings nuevos están traducidos | ⬜ | |

---

## Bloque 10: Regresión Sprint 2 (smoke test)

| # | Verificación | Resultado | Notas |
|---|---|---|---|
| 10.1 | Login y registro funcionan sin cambios | ⬜ | |
| 10.2 | Crear sueño sin audio (solo texto) sigue funcionando | ⬜ | |
| 10.3 | Editar y eliminar sueños sin audio sigue funcionando | ⬜ | |
| 10.4 | Lista de sueños muestra sueños con y sin audio sin error | ⬜ | |
| 10.5 | Perfil guarda correctamente nombre y preferencias de notificación | ⬜ | |

---

## Resumen de validación

| Bloque | Items Obligatorios | Estado |
|---|---|---|
| 1. Entorno y compilación | 1.1 a 1.5 | ⬜ |
| 2. Permisos micrófono | 2.1 a 2.4 | ⬜ |
| 3. Grabación de audio | 3.1 a 3.7 | ⬜ |
| 4. Subida a Storage | 4.1 a 4.6 | ⬜ |
| 5. Reproducción de audio | 5.1 a 5.8 | ⬜ |
| 6. Clave API Gemini | 6.1 a 6.7 | ⬜ |
| 7. Análisis IA Gemini | 7.1 a 7.8 | ⬜ |
| 8. Seguridad y privacidad | 8.1 a 8.4 | ⬜ |
| 9. UI y accesibilidad | 9.1 a 9.6 | ⬜ |
| 10. Regresión Sprint 2 | 10.1 a 10.5 | ⬜ |

---

## Decisión del Product Owner

- Fecha de validación: _______________
- Validado por: _______________
- Resultado: ⬜ Aprobado | ⬜ Aprobado con ajustes | ⬜ Rechazado
- Ajustes requeridos (si aplica):
  
  _______________________

- Acciones para Sprint 4:

  _______________________

---

## Notas técnicas para el validador

### Cómo obtener una clave Gemini
1. Accede a [Google AI Studio](https://aistudio.google.com/).
2. Crea un proyecto y genera una API Key.
3. En la app: Perfil → campo "Clave API de Gemini" → pegar clave → guardar.
4. La clave se almacena localmente (SharedPreferences) en el dispositivo, nunca en la nube.

### Verificar Firebase Storage
- Accede a Firebase Console → Storage → Files.
- Navega a `users/{uid}/dreams/{dreamId}/audio.m4a`.
- El archivo debe existir si el sueño tiene `hasAudio: true` en Firestore.

### Dependencias requeridas en `pubspec.yaml` (ya presentes)
- `record: ^6.0.0` — grabación de audio.
- `just_audio: ^0.9.38` — reproducción de audio.
- `firebase_storage: ^11.6.5` — subida de archivos.
- `google_generative_ai: ^0.3.1` — Gemini API.
- `shared_preferences: ^2.3.2` — almacenamiento local de clave API.
