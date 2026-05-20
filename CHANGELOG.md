# Changelog — Hypnos Dream Journal

Este archivo documenta cada versión de la app, qué incluye y a qué rama/tag corresponde.

## Convención de versiones

| Tipo de cambio | Qué incrementa | Ejemplo |
|---|---|---|
| Nueva funcionalidad mayor / sprint completo | MINOR | 1.0.0 → 1.1.0 |
| Corrección de bugs o ajustes menores | PATCH | 1.1.0 → 1.1.1 |
| Rediseño o ruptura de compatibilidad | MAJOR | 1.x.x → 2.0.0 |

El build number (`+N`) se incrementa en cada build generado.

## Flujo rama → versión

```
feat/mvp-vX  →  merge a main  →  git tag vX.Y.Z  →  release APK
```

- Cada rama de feature al mergearse a `main` genera un nuevo tag semántico.
- El tag se crea **sobre el commit de merge en main**.
- La versión en `pubspec.yaml` se actualiza **en la rama** antes del merge.

---

## [1.1.0] — En desarrollo
**Rama:** `feat/mvp-v2`
**Estado:** 🔧 In Progress

### Cambios previstos
- [ ] (por definir con el usuario)

---

## [1.0.0] — 2026-05-16
**Rama:** `feat/mvp-v1` → mergeada a `main`
**Tag:** `v1.0.0`
**Estado:** ✅ Released

### Incluye
- **Auth:** registro, login, logout, Google Sign-In
- **Diario CRUD:** creación, edición y borrado de sueños con texto y audio
- **Audio:** grabación, reproducción y almacenamiento en Firebase Storage
- **IA (Gemini):** transcripción de audio, análisis emocional, interpretación de sueños
- **Dashboard:** evolución emocional, elementos recurrentes y patrones temporales
- **Perfil:** foto de perfil, datos personales, autenticación biométrica
- **i18n:** soporte ES / EN
- **Firebase:** Auth + Firestore + Storage con reglas de seguridad reales
- **Plataformas:** Android (primario), iOS, Web

---

## [0.1.0] — 2026-04-XX
**Rama:** `main` (setup inicial)
**Estado:** ✅ Base

### Incluye
- Setup inicial Flutter project
- Estructura de carpetas y arquitectura base
