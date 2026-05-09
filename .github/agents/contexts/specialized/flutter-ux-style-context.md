# Flutter UX Style Context

Contexto visual y de experiencia para Hypnos Dream Journal.

## Objetivo UX
- Flujo rapido para registrar suenos (texto o voz) en menos de 60 segundos.
- Lectura clara de patrones emocionales sin sobrecargar la pantalla.
## Direccion creativa
- Concepto rector: Minimalismo onirico de alta precision.
- Enfoque visual: claridad mental aplicada al contenido emocional del sueno.
- Estetica: premium sobria, sin simbolismo esoterico recargado.

## Principios de interfaz
- Priorizar claridad sobre decoracion.
- Jerarquia fuerte: captura, historial, analitica.
- Componentes consistentes y reutilizables.
- Accesibilidad first: contraste, tamano tactil y lectura por screen reader.
- Reducir friccion cognitiva en momentos de baja energia (recien despierto o antes de dormir).
- Una accion primaria evidente por pantalla.
- Texto y datos siempre comprensibles en menos de 3 segundos.

## Guiones de estilo base
- Definir tokens de color, tipografia y espaciado en un sistema central.
- Evitar estilos inline repetidos.
- Usar temas globales de Flutter para coherencia.

## Sistema visual (design tokens)

### Color tokens
- `bgPrimary`: #0A0C14 (Deep Obsidian)
- `surfaceGlass`: #1E2230 con alpha 0.60
- `textPrimary`: #F8F9FA
- `textSecondary`: #F8F9FA con alpha 0.70
- `accentPrimary`: #00F5FF (Lucid Cyan, IA y accion)
- `accentSecondary`: #8A2BE2 (Dream Violet, emociones y analisis)
- `borderSubtle`: #FFFFFF con alpha 0.10
- `success`: #4ADE80
- `warning`: #F59E0B
- `error`: #F43F5E

### Reglas de uso de color
- `accentPrimary` para CTA principal, foco y estados activos.
- `accentSecondary` para insights emocionales y categorias cualitativas.
- No usar negro puro para fondos extensos.
- Sombras siempre con tinte de acento y opacidad 0.10-0.15 (sin sombra negra dura).

### Tipografia
- UI y datos: Satoshi; fallback recomendado Inter.
- Narrativa de suenos: Lora.
- Escala base:
	- Display: 28/32 semibold
	- H1: 24/30 bold
	- H2: 20/26 semibold
	- Body: 16/24 regular
	- Body dream text: 18/29 regular (Lora, para lectura prolongada)
	- Caption: 12/16 medium

### Espaciado, radios y bordes
- Escala de espaciado: 4, 8, 12, 16, 24, 32.
- Radius principal: 24 (cards hero).
- Radius secundario: 16 (cards comunes).
- Radius pildora/chips: 999.
- Borde estandar: 1px `borderSubtle`.

### Blur y superficies
- Tarjetas glass: blur 15px.
- Tab bar: blur 20px.
- Superficies translucidas deben mantener contraste AA con el texto.

## Patrones de pantalla
- Home: acceso directo a nueva entrada.
- Nueva entrada: opcion texto/voz con estados de grabacion claros.
- Historial: lista cronologica filtrable.
- Dashboard: foco en tendencias, no en ruido.

## Especificaciones por pantalla

### Home Dashboard (centro de control)
- Header:
	- Saludo contextual: "Buenos dias, [Nombre]".
	- Avatar de perfil 32x32 con borde sutil en `accentPrimary`.
- Hero card (zona superior dominante):
	- Orbe central de marca.
	- Mensaje breve: "Morfeo te escucha".
	- Card completa clicable para iniciar captura.
- Fila inferior de mini-cards:
	- "Anoche": resumen corto del ultimo sueno (tipografia narrativa).
	- "Estado de animo": mini grafica de 3 emociones maximo.
- Bottom nav:
	- Fondo con blur 20.
	- Items: Home, Historial, Estadisticas, Ajustes.

### Captura activa (estado de trance)
- Fondo radial sobrio:
	- Centro aproximado #1A1D2E.
	- Bordes #0A0C14.
- Orbe 200x200 con pulso respiratorio continuo.
- Voice waveform reactivo en `accentPrimary`.
- Acciones:
	- Boton principal circular para detener.
	- Accion secundaria textual: "Prefiero escribir".
- Privacidad:
	- Indicador visible de cifrado de extremo a extremo.

### Analisis y diario (revelacion)
- Header con volver y fecha del sueno.
- Bloque principal del relato en Lora, alta legibilidad.
- Panel de Morfeo AI:
	- Titulo y estado emocional principal (pill).
	- Entidades detectadas en chips.
	- Correlacion contextual en texto breve (sueno/estres/habitos).
- Sticky bottom:
	- CTA primario: guardar en diario.
	- CTA secundario: compartir analisis.

## Componentes UX reutilizables
- `GlassCard`: fondo translcido + borde sutil + blur.
- `HypnosOrb`: variante idle, listening, processing.
- `VoiceWaveform`: visual en tiempo real con fallback estatico.
- `EmotionPill`: estado emocional principal por color.
- `EntityChip`: taxonomia de entidades extraidas.
- `BottomNavBlur`: navegacion consistente global.
- `PrimaryCTA` y `SecondaryCTAOutline`: jerarquia de acciones.

## Movimiento e interaccion
- Transiciones de navegacion: Fade o SlideUp, 300ms, curva easeOutCubic.
- Microanimaciones: suaves, intencionales, nunca decorativas por defecto.
- Grabacion activa: pulso del orbe con ciclo respiratorio calmado.
- Soporte de accesibilidad: reducir intensidad si el sistema indica reduced motion.

## Criterios de calidad UX
- Tiempo medio de captura bajo.
- Errores de validacion comprensibles.
- Navegacion predecible y sin callejones.

## Metricas UX recomendadas
- Tiempo a primera palabra en captura (objetivo < 8s desde Home).
- Tiempo total de registro (objetivo < 60s).
- Tasa de abandono en captura.
- Tasa de guardado exitoso tras analisis.

## Guia de implementacion Flutter
- Centralizar tokens en tema global (`ThemeData` + `ColorScheme` + extensiones de tema).
- Evitar estilos hardcodeados en widgets de pantalla.
- Componentizar por responsabilidad visual y estado.
- Validar en mobile primero (portrait) y luego adaptar tablet/web.
- Mantener consistencia entre plataformas sin romper patron de navegacion principal.
- Priorizar tipografia de sistema si Satoshi no esta disponible para evitar regresion de rendimiento.

## Criterios de aceptacion UX
- El flujo Home -> Captura -> Guardar puede completarse sin dudas ni pasos ocultos.
- La accion primaria siempre es visible sin scroll en mobile.
- Todos los controles clave tienen label accesible para lector de pantalla.
- Contraste y legibilidad verificados en uso nocturno.
