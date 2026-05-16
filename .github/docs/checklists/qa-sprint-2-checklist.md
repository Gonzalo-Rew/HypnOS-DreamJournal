# Checklist QA - Sprint 2 (Fase 2: Desarrollo del Core)

Proposito: validacion funcional del incremento entregado al Product Owner.
App: Hypnos Dream Journal
Estado: Pendiente de ejecucion

Instrucciones:
- Marcar con [x] cada item al verificarlo.
- Anotar resultado en columna de observaciones.
- Un criterio fallido = bloqueo para cierre del sprint.

---

## Bloque 1 - Entorno y arranque

| # | Verificacion | Resultado | Observaciones |
|---|-------------|----------|--------------|
| 1.1 | App arranca sin errores en emulador Pixel 4 (pequeno) | [X] Pass / [ ] Fail | |
| 1.2 | App arranca sin errores en emulador Pixel 7 (medio) | [X] Pass / [ ] Fail | |
| 1.3 | App arranca sin errores en emulador Pixel Tablet (grande) | [X] Pass / [ ] Fail | |
| 1.4 | App arranca sin errores en dispositivo fisico Android | [X] Pass / [ ] Fail | |
| 1.5 | No aparece mensaje de crash ni pantalla roja en arranque | [X] Pass / [ ] Fail | |

---

## Bloque 2 - Autenticacion

| # | Verificacion | Resultado | Observaciones |
|---|-------------|----------|--------------|
| 2.1 | Pantalla de Login se muestra correctamente | [X] Pass / [ ] Fail | |
| 2.2 | Registro de usuario nuevo con email y contrasena funciona | [X] Pass / [ ] Fail | |
| 2.3 | Error visible si email ya existe al registrar | [X] Pass / [] Fail | |
| 2.4 | Error visible si contrasena es demasiado corta | [X] Pass / [ ] Fail | |
| 2.5 | Login con credenciales correctas navega a Home | [X] Pass / [ ] Fail | |
| 2.6 | Login con credenciales incorrectas muestra error claro | [X] Pass / [ ] Fail | |
| 2.7 | Cerrar y reabrir la app mantiene la sesion activa | [X] Pass / [ ] Fail | |
| 2.8 | Logout desde Perfil cierra sesion y vuelve a Login | [X] Pass / [ ] Fail | |

---

## Bloque 3 - Home

| # | Verificacion | Resultado | Observaciones |
|---|-------------|----------|--------------|
| 3.1 | Pantalla Home se muestra tras login | [X] Pass / [ ] Fail | |
| 3.2 | Boton/acceso a nueva entrada visible y funcional | [X] Pass / [ ] Fail | |
| 3.3 | Acceso a lista de suenos visible y funcional | [X] Pass / [ ] Fail | |
| 3.4 | Acceso a Perfil visible y funcional | [X] Pass / [ ] Fail | |

---

## Bloque 4 - Creacion de suenos

| # | Verificacion | Resultado | Observaciones |
|---|-------------|----------|--------------|
| 4.1 | Formulario de nueva entrada se abre correctamente | [X] Pass / [ ] Fail | |
| 4.2 | Campo de texto del sueno acepta texto largo | [X] Pass / [ ] Fail | |
| 4.3 | Campo de notas de contexto (contextNotes) disponible | [X] Pass / [ ] Fail | |
| 4.4 | Selector de mood disponible con rango 1-5 | [X] Pass / [ ] Fail | |
| 4.5 | Error si se intenta guardar sin texto del sueno | [X] Pass / [ ] Fail | |
| 4.6 | Error si moodScore esta fuera del rango 1-5 | [X] Pass / [ ] Fail | |
| 4.7 | Guardar sueno correcto lo persiste en Firestore | [X] Pass / [ ] Fail | |
| 4.8 | Tras guardar, el sueno aparece en la lista | [X] Pass / [ ] Fail | |

---

## Bloque 5 - Lista de suenos

| # | Verificacion | Resultado | Observaciones |
|---|-------------|----------|--------------|
| 5.1 | Lista muestra suenos en orden cronologico | [X] Pass / [ ] Fail | |
| 5.2 | Cada item de lista muestra preview (titulo o texto + mood) | [X] Pass / [ ] Fail | |
| 5.3 | Estado vacio correcto cuando no hay suenos | [X] Pass / [ ] Fail | |
| 5.4 | Tap en sueno abre pantalla de detalle | [X] Pass / [ ] Fail | |
| 5.5 | Lista se actualiza en tiempo real al crear un sueno nuevo | [X] Pass / [ ] Fail | |

---

## Bloque 6 - Detalle y edicion de suenos

| # | Verificacion | Resultado | Observaciones |
|---|-------------|----------|--------------|
| 6.1 | Pantalla de detalle muestra texto completo del sueno | [X] Pass / [ ] Fail | |
| 6.2 | Muestra contextNotes si tiene valor | [X] Pass / [ ] Fail | |
| 6.3 | Muestra moodScore correctamente | [X] Pass / [ ] Fail | añadir un tool tip para explicar que es exactamente lo que incluye |
| 6.4 | Boton de editar abre formulario con datos precargados | [X] Pass / [ ] Fail | |
| 6.5 | Guardar edicion actualiza los datos en Firestore | [X] Pass / [ ] Fail | |
| 6.6 | Boton de eliminar muestra dialogo de confirmacion | [X] Pass / [ ] Fail |El dialogo de confimación es demasiado transparente, no se llegua a distinguir correctamente el texto|
| 6.7 | Confirmar eliminacion borra el sueno de Firestore y lista | [X] Pass / [ ] Fail | |
| 6.8 | Cancelar eliminacion no borra el sueno | [X] Pass / [ ] Fail | |

---

## Bloque 7 - Perfil

| # | Verificacion | Resultado | Observaciones |
|---|-------------|----------|--------------|
| 7.1 | Pantalla de Perfil muestra email del usuario | [ ] Pass / [ ] Fail | |
| 7.2 | Campo displayName es editable y se guarda | [ ] Pass / [ ] Fail | |
| 7.3 | Toggle de notificaciones funciona y persiste | [ ] Pass / [ ] Fail | |
| 7.4 | Selector de hora de notificacion funciona y persiste | [ ] Pass / [ ] Fail | |
| 7.5 | Botton de logout funciona y vuelve a Login | [ ] Pass / [ ] Fail | |

---

## Bloque 8 - Seguridad de datos

| # | Verificacion | Resultado | Observaciones |
|---|-------------|----------|--------------|
| 8.1 | Un usuario no ve suenos de otro usuario | [ ] Pass / [ ] Fail | Probar con 2 cuentas |
| 8.2 | Al hacer logout y login con otra cuenta, lista esta vacia o muestra solo sus suenos | [ ] Pass / [ ] Fail | |

---

## Bloque 9 - Resolucion y UI

| # | Verificacion | Resultado | Observaciones |
|---|-------------|----------|--------------|
| 9.1 | Textos no se cortan en Pixel 4 (pequeno) | [ ] Pass / [ ] Fail | |
| 9.2 | Botones son accesibles y no se solapan en pantalla pequena | [ ] Pass / [ ] Fail | |
| 9.3 | Layout correcto en Pixel Tablet (pantalla grande) | [ ] Pass / [ ] Fail | |
| 9.4 | Orientacion horizontal no rompe la UI | [ ] Pass / [ ] Fail | |
| 9.5 | Teclado no tapa campos de entrada en formularios | [ ] Pass / [ ] Fail | |

---

### Fallos a correjir - mejorar
- No permite introducir caracteres como la ñ o letras con acentos



