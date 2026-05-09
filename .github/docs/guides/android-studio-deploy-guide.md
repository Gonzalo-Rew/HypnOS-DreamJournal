# Guia de Despliegue en Android Studio - Hypnos Dream Journal

Sprint: 2 (Fase 2 - Desarrollo del Core)
Proposito: ejecutar y probar la app en emuladores de distintas resoluciones.

---

## Requisitos previos

- Android Studio instalado (Ladybug o superior recomendado).
- Flutter SDK instalado y configurado en PATH.
- Plugin de Flutter instalado en Android Studio (File > Settings > Plugins > buscar "Flutter").
- Plugin de Dart instalado (se instala junto a Flutter).
- `flutter doctor` sin errores criticos en terminal.

Verificar entorno antes de empezar:
```
flutter doctor
```
Deben estar en verde: Flutter, Android toolchain, Android Studio.

---

## Paso 1 - Abrir el proyecto

1. Abrir Android Studio.
2. File > Open.
3. Seleccionar la carpeta raiz del proyecto: `c:\Users\ludig\Desktop\hypnos_dreamjournal`.
4. Esperar a que Gradle sincronice (barra de progreso inferior).
5. Si Gradle pide actualizar version, aceptar.

---

## Paso 2 - Crear emuladores de distintas resoluciones

Abrir Device Manager:
- Icono de dispositivo en la barra lateral derecha, o
- Tools > Device Manager.

Crear 3 dispositivos virtuales para cubrir resoluciones distintas:

### Dispositivo 1 - Telefono pequeno
- Clic en "+" o "Create Virtual Device".
- Categoria: Phone.
- Modelo: Pixel 4 (5.7", 1080x2280, 440dpi).
- Sistema: Android 13 (API 33) o Android 14 (API 34).
- Nombre sugerido: `Pixel4_pequeno`.

### Dispositivo 2 - Telefono medio (principal de desarrollo)
- Modelo: Pixel 7 (6.3", 1080x2400, 429dpi).
- Sistema: Android 13 (API 33).
- Nombre sugerido: `Pixel7_medio`.

### Dispositivo 3 - Pantalla grande / tablet
- Categoria: Tablet.
- Modelo: Pixel Tablet (10.95", 2560x1600).
- Sistema: Android 13 (API 33).
- Nombre sugerido: `PixelTablet_grande`.

Clic en "Finish" para cada dispositivo.

---

## Paso 3 - Ejecutar la app en emulador

### Opcion A - Desde Android Studio (recomendado)
1. En la barra superior, seleccionar el emulador en el selector de dispositivos.
2. Clic en el boton "Run" (triangulo verde) o Shift+F10.
3. Esperar a que el emulador arranque y la app se instale.

### Opcion B - Desde terminal integrado
```
flutter devices
flutter run -d nombre_o_id_emulador
```

Ejemplo:
```
flutter run -d emulator-5554
```

### Opcion C - Hot Reload durante desarrollo
Con la app corriendo, hacer cambios en el codigo y pulsar:
- `r` en terminal para hot reload (recarga widgets sin perder estado).
- `R` para hot restart (reinicia la app completamente).
- En Android Studio: boton de rayo (hot reload) o boton de restart.

---

## Paso 4 - Probar en varias resoluciones

Con cada emulador creado:
1. Arrincar el emulador desde Device Manager (boton play).
2. Correr la app con `flutter run` seleccionando ese emulador.
3. Probar el flujo completo (ver checklist de QA).
4. Verificar que los textos no se cortan, botones son accesibles y el formulario de suenos es usable.
5. Rotar el emulador (Ctrl+F11 o boton de rotacion en panel lateral) y revisar orientacion horizontal.

---

## Paso 5 - Desplegar en dispositivo fisico Android (validacion final)

1. Conectar el telefono por USB.
2. Activar "Opciones de desarrollador" en el telefono:
   - Ajustes > Acerca del telefono > tocar "Numero de compilacion" 7 veces.
3. Activar "Depuracion USB" dentro de Opciones de desarrollador.
4. Aceptar el dialogo de "Permitir depuracion USB" en el telefono.
5. Verificar que Flutter detecta el dispositivo:
   ```
   flutter devices
   ```
6. Ejecutar:
   ```
   flutter run -d id_del_dispositivo
   ```

---

## Paso 6 - Build de release (para demo al Product Owner)

Build debug (para pruebas internas):
```
flutter build apk --debug
```
Archivo generado: `build/app/outputs/flutter-apk/app-debug.apk`

Build release (para demo formal):
```
flutter build apk --release
```
Nota: el build release requiere configurar una keystore de firma. Para demos iniciales usar debug.

---

## Problemas comunes y soluciones

| Problema | Solucion |
|---------|---------|
| Gradle sync falla | File > Invalidate Caches > Restart |
| flutter doctor muestra Android licenses | Ejecutar: `flutter doctor --android-licenses` y aceptar todo |
| Emulador muy lento | Activar HAXM en BIOS o usar emuladores ARM si el PC es ARM |
| App crashea al iniciar | Verificar que Firebase esta configurado en consola (Auth y Firestore activos) |
| "SDK not found" | Verificar que flutter.sdk esta en android/local.properties apuntando al SDK correcto |
| Puerto ocupado | Cerrar otros emuladores y reintentar |

---

## Configuracion actual del proyecto

- compileSdk: usa version del SDK de Flutter automaticamente.
- minSdk: version minima de Flutter.
- targetSdk: version objetivo de Flutter.
- google-services plugin: 4.4.4 (verificado y sincronizado).
- Firebase: proyecto `hypnos-deamjournal` configurado para Android e iOS.
- Namespace: `com.example.hypnos_dreamjournal`.
