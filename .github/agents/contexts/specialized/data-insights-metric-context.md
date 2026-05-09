# Data Insights Metric Context

Marco para analitica de producto y patrones de sueno.

## Objetivo
- Medir evolucion emocional y adherencia al uso del diario.
- Detectar patrones temporales y recurrencias de contenido.

## Eventos de producto base
- dream_entry_created
- dream_entry_updated
- dream_entry_deleted
- audio_record_started
- audio_record_saved
- analysis_requested
- analysis_completed

## Dimensiones sugeridas
- fecha_local
- metodo_entrada (texto, voz)
- duracion_audio
- sentimiento_global
- entidades_detectadas (personaje, lugar, emocion)

## Reglas
- No registrar contenido sensible en texto plano fuera de almacenamiento autorizado.
- Mantener trazabilidad entre evento y objetivo de producto.
- Priorizar metrica accionable para dashboard.
