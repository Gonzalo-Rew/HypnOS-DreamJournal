# Memoria del Proyecto - Hypnos Dream Journal (Borrador)

## Resumen
Hypnos Dream Journal es una aplicacion multiplataforma orientada al registro y analisis de suenos con apoyo de servicios cloud e inteligencia artificial. El proyecto se plantea como una solucion mHealth centrada en la captura de informacion onirica en formatos de texto y audio, su persistencia segura en Firebase y su explotacion analitica para identificar patrones emocionales y de contenido a lo largo del tiempo.

Desde una perspectiva tecnica, la solucion integra una aplicacion cliente en Flutter (Dart), un backend serverless en Firebase (Authentication, Firestore, Storage y Cloud Functions) y un flujo de analisis IA para enriquecer semanticamente los registros. El resultado es una plataforma que combina usabilidad, trazabilidad de datos y capacidad de evolucion incremental.

## 1. Introduccion
El registro de suenos ha sido historicamente una practica personal de caracter narrativo y subjetivo. Sin embargo, en su forma tradicional presenta dos limitaciones principales: dificultad para mantener la constancia en el tiempo y baja capacidad para extraer patrones utiles cuando el volumen de entradas crece.

A partir de esta necesidad, el proyecto Hypnos Dream Journal propone una aplicacion movil que facilita el registro rapido de suenos y transforma datos no estructurados en informacion accionable. La propuesta tecnica combina captura multimedia, persistencia cloud, analitica y una capa de interpretacion asistida por IA, siempre bajo criterios de seguridad y control de acceso por usuario.

## 2. Origen y motivacion del proyecto
El origen del proyecto parte de una motivacion doble: por un lado, mejorar la adherencia al habito de registrar suenos mediante una experiencia de uso accesible; por otro, ampliar el valor del registro mediante tecnicas de analisis automatizado.

En el contexto academico del TFG, el proyecto permite abordar de forma integrada varias competencias: arquitectura de software multiplataforma, diseno de backend seguro, procesamiento cloud, validacion de calidad y documentacion tecnica profesional. La motivacion tecnica se centra en resolver un problema real de integracion entre cliente movil, nube y analitica, manteniendo una base de codigo mantenible y extensible.

## 3. Objetivos
### 3.1 Objetivo general
Disenar e implementar una aplicacion multiplataforma para registrar suenos en formato textual y de audio, almacenarlos de forma segura en la nube y proporcionar analisis asistido por IA para detectar patrones de interes.

### 3.2 Objetivos especificos
1. Implementar autenticacion de usuarios y gestion de perfil con persistencia segura.
2. Desarrollar un modulo CRUD de suenos con soporte de texto, audio y metadatos asociados.
3. Integrar servicios Firebase para datos, ficheros y logica cloud.
4. Incorporar un flujo de analisis IA capaz de generar categorias, resumen y etiquetas semanticas.
5. Implementar controles de seguridad y privacidad alineados con buenas practicas de minimo privilegio.
6. Validar la solucion con un plan de pruebas funcional y tecnica de release.
7. Generar documentacion tecnica separada y trazable como soporte de la memoria principal.

## 4. Alcance y limitaciones
### 4.1 Alcance funcional
El alcance funcional incluye autenticacion, gestion de perfil, creacion y mantenimiento de suenos, funcionalidades sociales basicas, notificaciones y analitica de contenido mediante IA. La aplicacion esta planteada para Android e iOS como plataformas prioritarias, manteniendo compatibilidad de framework con otros targets.

### 4.2 Alcance tecnico
La arquitectura se apoya en Flutter para cliente, Firebase como backend serverless y Cloud Functions para logica de procesamiento. El proyecto contempla despliegues iterativos, control de cambios y trazabilidad de evolucion tecnica.

### 4.3 Limitaciones
1. El analisis IA depende de servicios externos y puede verse afectado por latencia, cuota o disponibilidad.
2. Algunas funciones avanzadas de observabilidad y automatizacion pueden requerir madurez adicional en fases posteriores.
3. La calidad de salida del analisis puede variar en entradas ambiguas o demasiado breves.

## 5. Metodologia y plan de desarrollo
El desarrollo sigue un enfoque incremental por fases y sprints, con cierre de entregables verificables en cada iteracion. Este enfoque permite reducir riesgo de integracion, introducir validaciones tempranas y ajustar prioridades segun resultados.

### 5.1 Fases de trabajo
1. Analisis y diseno.
2. Desarrollo del core.
3. Integracion multimedia e IA.
4. Analitica, mejoras de UX y consolidacion.

### 5.2 Criterios de validacion por sprint
Cada sprint se considera cerrado cuando existe incremento funcional utilizable, evidencias tecnicas de validacion y trazabilidad de cambios en la documentacion de proyecto.

## 6. Arquitectura tecnica de la solucion
La solucion adopta un modelo cliente-cloud desacoplado:
1. Cliente Flutter: interfaz, gestion de estado, navegacion y consumo de servicios.
2. Firebase Auth: identidad y sesion.
3. Firestore: persistencia estructurada de perfiles y suenos.
4. Firebase Storage: almacenamiento de audio.
5. Cloud Functions: logica de negocio serverless y flujo IA.

Este modelo permite escalar por componentes, aplicar reglas de acceso por recurso y mantener bajo acoplamiento entre UI y backend.

## 7. Tecnologias, herramientas y librerias
### 7.1 Stack principal
1. Flutter / Dart para desarrollo multiplataforma.
2. Firebase (Auth, Firestore, Storage, Functions) para backend cloud.
3. Integracion IA con modelo generativo a traves de Functions.

### 7.2 Herramientas de apoyo
1. Control de versiones con Git.
2. Checklists y planes QA para validacion funcional.
3. Documentacion tecnica de despliegue, riesgos y runbooks operativos.

## 8. Seguridad, privacidad y cumplimiento tecnico
La aplicacion se basa en reglas de seguridad con modelo de propietario por usuario, validaciones de acceso y procedimientos de despliegue controlado. Se incluyen mecanismos de consentimiento y consideraciones de privacidad en flujos sensibles (perfil, datos personales, funciones sociales y borrado de cuenta).

[Pendiente de completar con detalle normativo segun plantilla PFC y guia oficial].

## 9. Estrategia de pruebas y calidad
El proyecto dispone de plan de pruebas funcional y checklist de release para validar rutas criticas: autenticacion, CRUD de suenos, audio, dashboard, notificaciones e integracion IA. La calidad se evalua mediante ejecucion de casos, analisis de incidencias y verificacion de regresion en funcionalidades clave.

[Pendiente de incorporar metricas finales por build/version].

## 10. Resultados obtenidos
[Pendiente de completar con resultados finales cuantitativos y cualitativos: funcionalidades cerradas, estabilidad, incidencias resueltas y evidencia de uso].

## 11. Costes del proyecto
[Pendiente de completar: estimacion de costes de desarrollo, operacion cloud (Firebase/Functions), y escenarios de escalado].

## 12. Conclusiones y lineas futuras
El proyecto demuestra la viabilidad de integrar captura multimedia, backend cloud seguro y analitica IA en una aplicacion movil orientada a diario onirico. La arquitectura adoptada facilita iteracion y mantenimiento, y abre lineas futuras en personalizacion de analisis, observabilidad avanzada y optimizacion de costes.

## 13. Referencias bibliograficas (formato IEEE)
[Pendiente de completar con fuentes reales en estilo IEEE].

Ejemplo de formato IEEE:
[1] Autor, "Titulo del recurso", Editorial/Revista/Sitio, ano. [Online]. Available: URL
