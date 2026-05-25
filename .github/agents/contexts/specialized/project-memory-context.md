# Project Memory Context

Este archivo define el marco de trabajo para elaborar la memoria del proyecto y manuales del TFG.

## Objetivo
- Producir una memoria tecnica evaluable y manuales asociados con trazabilidad a evidencia real del proyecto.

## Alcance documental principal
- Memoria del proyecto (documento evaluable principal).
- Manuales tecnicos y de uso vinculados al alcance del modulo.
- Secciones esperadas: origen y motivacion, metodologia, arquitectura, tecnologias/librerias, desarrollo, pruebas, despliegue, costes, riesgos y conclusiones.

## Criterios de calidad
- Redaccion formal, clara y verificable.
- Coherencia entre narrativa y estado real del repositorio.
- Citas y referencias en formato IEEE cuando corresponda.
- Trazabilidad: cada afirmacion tecnica relevante debe poder vincularse a evidencia.

## Fuentes de evidencia preferentes
- Codigo y configuracion del repositorio.
- Historial tecnico en .github/agents/contexts/shared/shared-lifecycle-history.md.
- Documentos de proyecto (README, guias, planes QA, riesgos, changelog).
- Aportes de agentes especialistas para validaciones de dominio.

## Entradas externas requeridas (pendientes)
- Guia Proyecto oficial (normas exactas de estructura y evaluacion).
- 2 TFG de referencia evaluados positivamente por tribunal.

## Politica de referencias IEEE
- Usar citas numericas [1], [2], [3] en el texto.
- Incluir listado final de referencias con formato IEEE completo.
- Si faltan metadatos (autor, anio, editorial, URL, DOI), marcar la referencia como incompleta antes de cerrar version.

## Coordinacion multiagente
- Infra Mobile Firebase AI: validacion de arquitectura, integraciones y despliegue.
- Firebase Backend Security Agent: seguridad, reglas y cumplimiento tecnico.
- Flutter UX App Agent: decisiones UI/UX y accesibilidad.
- Data Insights Agent: metricas, eventos y analitica.
- QA Release Agent: pruebas, cobertura y readiness.
- Software Decision Orchestrator: priorizacion y decisiones de alcance.

## Preferencias de redaccion acordadas
- Idioma principal: español.
- Tono: tecnico y entendible (formalidad media-alta).
- Nivel de formalidad objetivo: 6-7 sobre 10.
- Estructura documental: documentos tecnicos separados de la memoria principal.
- Conteo de palabras: aplica solo a la memoria principal (objetivo 10.000-15.000 palabras).
- Norma ortografica: usar tildes, eñes y puntuacion normativa del español en todos los borradores y versiones finales.

## Decisiones de estructura (2026-05-25)
- Se acuerda un indice inicial completo para memoria TFG en `docs/INDICE_MEMORIA_TFG_HYPNOS.txt`.
- Estructura base alineada con requisitos del centro: portada, indices opcionales, origen, introduccion, objetivos, tecnologia, metodologia/desarrollo, costes, conclusiones, mejoras y bibliografia IEEE.
- Se recomienda incluir anexos tecnicos (evidencias, diagramas, manuales) para reforzar evaluabilidad.
- Objetivo de redaccion: cierre entre 11.000 y 12.500 palabras, dentro del rango oficial 10.000-15.000.

## Avance de redaccion (2026-05-25)
- Se redacta borrador completo del apartado 1 (Origen y justificacion) en `docs/01_origen_y_justificacion_borrador.txt`.
- El texto integra motivación inicial validada por experiencia de registro personal de sueños y la transforma a narrativa académica impersonal.
- Se mantiene enfoque no clinico: apoyo al autoconocimiento y analitica personal, evitando afirmaciones diagnosticas.
- Se estructura en 1.1 motivacion y tematica, 1.2 campo de aplicacion, 1.3 antecedentes y competidores, 1.4 justificacion final.
- Se redacta borrador del apartado 2 (Introducción) en `docs/02_introduccion_borrador.txt`.
- El apartado 2 incorpora explicitamente el cambio de alcance frente al anteproyecto: inclusion de funcionalidades sociales no previstas inicialmente.
- Se documenta decision de naming (Hypnos/Morfeo) y concepto creativo de producto para contextualizar la identidad del proyecto.
- Se deja 2.4 (Estructura del documento) en estado pendiente, por acuerdo, hasta el cierre global de memoria.
- Se redacta borrador del apartado 3 (Objetivos) en `docs/03_objetivos_borrador.txt` con formato: objetivo general, objetivos especificos, criterios de exito y trazabilidad con anteproyecto.
- Se incorpora la ampliacion de alcance social (no prevista inicialmente) como objetivos especificos nuevos y se mantiene estado de cumplimiento en validacion pendiente para revision posterior del usuario.
- Para delimitar IA y seguridad se toma validacion de agente backend, evitando lenguaje clinico y sobreafirmaciones no evidenciadas.
- Se actualiza el apartado 3 a estado final de cumplimiento (objetivos superados) y se anade matriz objetivo-evidencia EV-xx para trazabilidad directa.
- Se crea plantilla de anexo de evidencias en `docs/ANEXO_B_EVIDENCIAS_TECNICAS.txt` con metodologia, estructura y matriz de 16 evidencias propuestas.
- Se explicita que el cierre de sesion se integra en autenticacion, el borrado de cuenta en ciclo de vida del dato y el tutorial inicial en el objetivo de experiencia multiplataforma/onboarding.
- Se redacta el borrador del apartado 4 en `docs/04_TECNOLOGIA_USADA_BORRADOR.txt` en version limpia (sin trazabilidad por rutas de archivo), incluyendo justificacion tecnica y criterios de seleccion.
- Se estructura Firebase por subsecciones (Auth, Firestore, Storage, Functions, Messaging), se explicita uso de Gemini 2.5 Flash y se menciona Stitch como apoyo de diseno no runtime.
- Se añade subapartado 4.3.5 para documentar el uso de GitHub Copilot y la estructura de agentes en `.github` (roles, categorias de permisos, contextos compartidos/especializados y registro de cambios).
- Se ajusta el apartado 5 en `docs/05_METODOLOGIA_Y_DESARROLLO_BORRADOR.txt` para que la concrecion tecnica comience en 5.5 inclusive, incorporando capas reales del repositorio, rutas de codigo, repositorios de datos y colecciones Firestore usadas por la aplicacion.
- Se matiza el bloque 5.11 para presentar las pruebas QA como validacion funcional manual y apoyo de depuracion, evitando afirmar la existencia de evidencias formales no conservadas.
- Se amplía 5.12 para documentar validacion en emuladores Android por tamanos de pantalla y en dispositivo fisico, ubicando esta informacion en despliegue y validacion en dispositivos.
- Se redacta el borrador del apartado 6 en `docs/06_MEDIOS_Y_CALCULO_DE_COSTES_BORRADOR.txt`, incorporando datos reales del usuario (horas, tarifa, desembolso de herramientas y consumo IA) y separando coste historico del TFG frente a coste operativo futuro por despliegue.
- Se define criterio economico de memoria en dos planos: coste ya ejecutado (desarrollo) y plan de explotacion con suscripcion para sostenibilidad de servicios IA.
- Se cierra la estructura del capitulo 6 en version definitiva de trabajo con: costes de publicacion en tiendas, suscripcion unica (mensual y anual), cobro nativo, escenarios de comision realistas y punto de equilibrio por margen neto.
- Se crea borrador tematico de capitulo 8 (`docs/08_BORRADOR_ESTRATEGIA_FUTURA_MODELO_NEGOCIO.txt`) centrado en monetizacion futura, marketing con microinfluencers, expectativas de conversion y evolucion del modelo IA con prioridad de calidad.
- Se actualiza la estrategia comercial a precio mensual de 3,99 EUR y se define acceso gratuito con 3 analisis IA en Gemini 2.5 Flash; el uso continuo de IA queda asociado a suscripcion con Gemini 2.5 Pro.
- Se redacta borrador del capitulo 7 en `docs/07_CONCLUSIONES_Y_PROBLEMAS_CONFRONTADOS_BORRADOR.txt`, estructurando resultados, incidencias reales, problemas comunes en proyectos similares y lecciones aprendidas.
- Se incorpora explicitamente la desviacion de alcance por entrada tardia del bloque social, su impacto en horas dedicadas y la menor madurez relativa de esa capa frente al nucleo diario+IA.
- Se amplía el borrador del capitulo 8 con dos lineas tecnicas de evolucion: control/refinamiento de llamadas y respuestas de Gemini (contratos, validacion, retries, observabilidad) y propuesta de servicio de generacion de imagen IA desde descripcion del sueno con control de coste y moderacion.
- Se crea el borrador del capitulo 9 en `docs/09_BIBLIOGRAFIA_IEEE_BORRADOR.txt` con referencias tecnicas/metodologicas en estilo IEEE y bloque de trazabilidad documental interna del proyecto.
- Se completa el apartado 2.4 (Estructura del documento) en `docs/02_introduccion_borrador.txt`, sustituyendo el placeholder pendiente por la descripcion final de capitulos, bibliografia IEEE y funcion de anexos de evidencia.
- Se insertan citas IEEE directamente en los borradores de capitulos 4, 5, 6, 7 y 8, y se amplia el capitulo 9 con referencias adicionales para VS Code y memorias de referencia usadas en comparativa de problemas comunes.
- Se crea el Anexo A en `docs/ANEXO_A_GLOSARIO_Y_ACRONIMOS_BORRADOR.txt`, con definiciones tecnicas y acronimos alineados al stack real del proyecto y a la narrativa de memoria TFG.
- Se crea el Anexo C en `docs/ANEXO_C_DIAGRAMAS_BORRADOR.txt` con enfoque realista: referencia al Gantt ya incluido y diagramas tecnicos de apoyo (arquitectura por capas, flujo IA y esquema documental Firestore), explicitando que no se elaboro un paquete UML formal extenso durante la ejecucion del TFG.
- Se crea el Anexo D en `docs/ANEXO_D_MANUAL_BREVE_USUARIO_BORRADOR.txt` como manual funcional resumido para uso de la aplicacion.
- Se crea el Anexo E en `docs/ANEXO_E_MANUAL_TECNICO_DESPLIEGUE_BORRADOR.txt` como guia operativa de entorno, ejecucion, validacion y despliegue tecnico.

## Gaps de evidencia abiertos
- Falta consolidar evidencia cuantitativa de pruebas (resultados finales, cobertura o metricas de validacion).
- Falta consolidar costes con cifras finales (infra, horas estimadas, coste operativo y mantenimiento).
- Falta cerrar listado bibliografico IEEE definitivo con metadatos completos para todas las fuentes.

## Ultima actualizacion
- Fecha: 2026-05-25
- Nota: Se anade decision de indice oficial inicial, objetivo de palabras y brechas de evidencia para siguientes iteraciones de memoria.
