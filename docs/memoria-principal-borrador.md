# Memoria del Proyecto

## HypnOS: aplicación multiplataforma para registro y análisis onírico con inteligencia artificial

Autor: Gonzalo Calvo Engelmo  
Tutor: Pablo Núñez  
Titulación: Ciclo Formativo de Grado Superior en Desarrollo de Aplicaciones Multiplataforma  
Curso académico: 2025-2026

## Resumen
HypnOS Dream Journal es una aplicación multiplataforma orientada al registro, almacenamiento y análisis de sueños mediante servicios cloud e inteligencia artificial. El proyecto se enmarca en el ámbito mHealth y bienestar digital, con el objetivo de transformar el diario onírico tradicional en una herramienta tecnológica capaz de aportar valor práctico al usuario.

La solución permite capturar sueños en texto y audio, gestionarlos de forma segura en la nube y enriquecerlos con un análisis semántico asistido por IA. Desde una perspectiva de ingeniería, combina cliente Flutter (Dart), backend serverless sobre Firebase (Authentication, Firestore, Storage y Cloud Functions), y mecanismos de validación y trazabilidad para sostener una evolución continua del producto.

## 1. Introducción
El registro de sueños ha sido históricamente una práctica de introspección personal, utilizada tanto en contextos terapéuticos como de autoconocimiento. No obstante, los métodos tradicionales presentan limitaciones claras: fricción de uso, baja consistencia en el hábito y escasa capacidad de análisis longitudinal.

HypnOS nace para resolver estas limitaciones mediante una aproximación tecnológica centrada en tres ejes: facilitar la captura de contenido al despertar, estructurar datos no estructurados y convertir ese contenido en información interpretable para el usuario. De este modo, el diario deja de ser un repositorio pasivo de textos y se convierte en una herramienta activa de seguimiento emocional.

## 2. Origen, motivación y evolución del proyecto
El anteproyecto definía una idea base: una app mHealth para diario onírico con entrada híbrida de datos e integración con IA. Esta visión inicial se ha mantenido, pero durante el desarrollo se han producido decisiones de diseño y arquitectura que han ampliado su alcance funcional real.

La evolución más relevante del proyecto puede resumirse en cuatro dimensiones:
1. De prototipo funcional a arquitectura modular mantenible.
2. De almacenamiento básico a modelo cloud con reglas de acceso por usuario.
3. De análisis IA teórico a pipeline operativo en Cloud Functions.
4. De app individual a componente social con privacidad configurable.

### 2.1 Decisión de naming y temática
La identidad del proyecto responde a una decisión intencional de marca:
1. Hypnos, en referencia al dios griego del sueño.
2. HypnOS, como juego de palabras con operating system.

Esta dualidad aporta coherencia conceptual entre temática onírica y enfoque tecnológico, y posiciona la aplicación como un sistema personal de gestión del mundo onírico.

## 3. Objetivos
### 3.1 Objetivo general
Diseñar e implementar una aplicación multiplataforma para registrar sueños en formato textual y de audio, almacenarlos de forma segura en la nube y ofrecer análisis asistido por IA para detectar patrones de interés emocional y narrativo.

### 3.2 Objetivos específicos
1. Implementar autenticación de usuarios y gestión de perfil con persistencia segura.
2. Desarrollar un módulo CRUD de sueños con soporte de texto, audio y metadatos asociados.
3. Integrar servicios Firebase para almacenamiento, sincronización y lógica backend.
4. Incorporar un flujo de análisis IA capaz de generar categorías, resumen y etiquetas semánticas.
5. Implementar controles de seguridad y privacidad alineados con el principio de mínimo privilegio.
6. Validar la solución mediante un plan de pruebas funcional y checklist de release.
7. Elaborar documentación técnica separada y trazable como soporte de la memoria principal.

## 4. Alcance y limitaciones
### 4.1 Alcance funcional
El alcance funcional actual incluye:
1. Registro e inicio de sesión de usuarios.
2. Creación, lectura, edición y eliminación de sueños.
3. Captura por texto y soporte de audio.
4. Integración de análisis IA de contenido.
5. Dashboard de información agregada.
6. Funcionalidades sociales básicas con control de privacidad.
7. Notificaciones y ajustes de cuenta/seguridad.

### 4.2 Alcance técnico
La arquitectura se apoya en Flutter para cliente, Firebase como backend serverless y Cloud Functions para lógica de procesamiento. El proyecto contempla despliegues iterativos, control de cambios y trazabilidad de evolución técnica.

### 4.3 Limitaciones
1. El análisis IA depende de servicios externos y puede verse afectado por latencia, cuota o disponibilidad.
2. La interpretación automática de texto narrativo tiene variabilidad inherente y no sustituye evaluación clínica.
3. La estrategia de observabilidad avanzada y automatización completa de CI/CD puede profundizarse en fases posteriores.

## 5. Metodología y plan de desarrollo
Aunque el anteproyecto planteaba Scrum con sprints quincenales, la ejecución real siguió un enfoque iterativo e incremental orientado por hitos funcionales y validación continua. Esta formulación describe con mayor precisión el proceso real de construcción.

### 5.1 Metodología aplicada
1. Desarrollo incremental por bloques funcionales prioritarios.
2. Integración continua de cambios de alto impacto técnico.
3. Validación progresiva con pruebas funcionales y revisiones de estabilidad.
4. Registro de decisiones e incidencias en historial técnico del proyecto.

### 5.2 Fases de trabajo ejecutadas
1. Análisis y diseño de flujo, datos y arquitectura base.
2. Implementación del core (auth, modelo de datos, CRUD).
3. Integración multimedia y pipeline de IA.
4. Ajustes de UX, seguridad, notificaciones y consolidación funcional.
5. Preparación de documentación técnica y memoria.

### 5.3 Criterios de validación
Cada iteración se considera válida cuando cumple:
1. Incremento funcional verificable.
2. Ausencia de errores críticos en rutas principales.
3. Evidencia técnica documentada.
4. Trazabilidad en documentos de proyecto.

## 6. Arquitectura técnica de la solución
La solución adopta un modelo cliente-cloud desacoplado:
1. Cliente Flutter: interfaz, navegación, estado y consumo de servicios.
2. Firebase Auth: identidad, sesión y vinculación de usuario.
3. Firestore: persistencia estructurada de perfiles, sueños y datos relacionados.
4. Firebase Storage: gestión de recursos de audio.
5. Cloud Functions: lógica serverless para procesamiento y eventos de negocio.

Este enfoque permite escalado por componentes, aislamiento de responsabilidades y control de acceso por recurso, reduciendo el acoplamiento entre capa de presentación y lógica backend.

## 7. Tecnologías, herramientas y librerías
### 7.1 Stack principal
1. Flutter/Dart como base multiplataforma.
2. Firebase (Auth, Firestore, Storage, Functions) como backend cloud.
3. Integración IA a través de Functions, con gestión de secretos en servidor.

### 7.2 Librerías clave en cliente
1. Gestión de estado y arquitectura de UI.
2. Reproducción y captura de audio.
3. Notificaciones push/locales.
4. Biometría y almacenamiento seguro local.
5. Localización e internacionalización.

### 7.3 Herramientas de apoyo
1. Git/GitHub para control de versiones.
2. Checklists QA y planes de pruebas para validación funcional.
3. Documentación técnica de despliegue, riesgos y operación.

## 8. Seguridad, privacidad y cumplimiento técnico
La seguridad se ha abordado de forma transversal en cliente y backend:
1. Reglas de acceso con propiedad por usuario en Firestore y Storage.
2. Validaciones de entrada y manejo de errores en Functions.
3. Protección de secretos en entorno servidor para integraciones IA.
4. Ajustes de privacidad y consentimiento en flujos legales.
5. Soporte de autenticación biométrica como capa adicional en cliente.

En cumplimiento de privacidad, el proyecto incorpora criterios de minimización, transparencia y trazabilidad de cambios sobre datos personales, especialmente en funcionalidades de perfil, interacción social y eliminación de cuenta.

## 9. Estrategia de pruebas y calidad
La validación de calidad combina plan de pruebas funcional y checklist de release, con foco en rutas críticas:
1. Auth (registro, login, recuperación, sesión).
2. CRUD de sueños y sincronización cloud.
3. Flujo de audio (grabación, reproducción, persistencia).
4. Integración IA y consistencia de resultados.
5. Notificaciones y preferencias de usuario.
6. Seguridad operativa y permisos.

La estrategia se apoya en ejecución iterativa, análisis de incidencias y verificación de regresión en funcionalidades de alto impacto para evitar degradaciones entre versiones.

## 10. Resultados obtenidos
El proyecto ha alcanzado un estado funcional sólido en su versión actual, con cobertura de los objetivos técnicos principales definidos en anteproyecto y refinados durante la ejecución.

Resultados destacables:
1. Plataforma cliente operativa con estructura modular y soporte multiplataforma.
2. Backend Firebase integrado con persistencia y seguridad por usuario.
3. Flujo de análisis onírico asistido por IA integrado en el producto.
4. Sistema de calidad con base documental de pruebas y checklist de release.
5. Trazabilidad de evolución técnica mediante historial compartido de cambios.

Además, se han resuelto incidencias relevantes en permisos, sincronización social, consistencia de análisis y notificaciones, lo que demuestra madurez progresiva del producto.

## 11. Costes del proyecto
El coste total del proyecto se divide en dos bloques: coste de desarrollo y coste operativo.

### 11.1 Coste de desarrollo
Incluye dedicación de análisis, implementación, depuración, validación y documentación.

Modelo de estimación recomendado para memoria:
1. Horas invertidas por fase.
2. Coste/hora teórico.
3. Coste total de desarrollo = horas x coste/hora.

### 11.2 Coste operativo técnico
Incluye infraestructura y herramientas:
1. Firebase (consumo según uso).
2. Cloud Functions (invocaciones y tiempo de ejecución).
3. Integración IA (coste variable por uso).
4. Herramientas de productividad/licencias.

### 11.3 Coste de distribución móvil
1. Google Play Console: pago único de alta de desarrollador.
2. Apple Developer Program: suscripción anual.

### 11.4 Escenarios de escalado
Se recomienda presentar tres escenarios:
1. Conservador: base de usuarios reducida.
2. Realista: crecimiento sostenido.
3. Optimista: adopción alta con uso frecuente de IA.

En cada escenario debe reflejarse:
1. Usuarios activos estimados.
2. Análisis IA por usuario/mes.
3. Coste mensual estimado.
4. Ingreso esperado por suscripción.
5. Punto de equilibrio.

## 12. Plan de despliegue y modelo de monetización
### 12.1 Plan de despliegue técnico
El plan de salida a producción se estructura en fases:
1. Beta cerrada con validación interna.
2. Publicación en Google Play (primer canal de distribución).
3. Publicación en App Store tras estabilización de operación y cumplimiento de requisitos de revisión.

### 12.2 Requisitos previos al release público
1. Checklist QA completo en rutas críticas.
2. Revisión de políticas legales y privacidad.
3. Verificación de telemetría mínima y alertado operativo.
4. Plan de rollback definido ante incidencia crítica.

### 12.3 Modelo de negocio propuesto
Se propone un modelo freemium con suscripción para el módulo de análisis IA:
1. Capa gratuita con funcionalidades base del diario.
2. Capa premium con análisis IA avanzado y mayor capacidad de uso.

Este enfoque permite controlar costes variables de IA y alinear ingresos con uso intensivo de cómputo.

## 13. Conclusiones y líneas futuras
HypnOS valida la viabilidad técnica y funcional de una aplicación de diario onírico con servicios cloud e IA, manteniendo un equilibrio entre usabilidad, seguridad y capacidad de evolución.

Desde la perspectiva de aprendizaje, el proyecto ha permitido consolidar competencias en arquitectura multiplataforma, backend serverless, seguridad de datos, integración IA y documentación técnica profesional.

Como líneas futuras, se propone:
1. Optimizar observabilidad y costes de inferencia IA.
2. Mejorar personalización de resultados y recomendaciones.
3. Refinar el modelo de suscripción según métricas reales de adopción.
4. Ampliar estrategia de testing automatizado.

## 14. Referencias bibliográficas (formato IEEE)
[Pendiente de cierre final con fuentes definitivas y fecha de consulta].

[1] Google, "Flutter documentation," 2026. [Online]. Available: https://docs.flutter.dev/

[2] Google, "Firebase documentation," 2026. [Online]. Available: https://firebase.google.com/docs

[3] Google AI for Developers, "Gemini API documentation," 2026. [Online]. Available: https://ai.google.dev/gemini-api/docs

[4] IEEE, "IEEE Editorial Style Manual," 2023. [Online]. Available: https://journals.ieeeauthorcenter.ieee.org/

[5] World Health Organization, "mHealth: New horizons for health through mobile technologies," 2011. [Online]. Available: https://apps.who.int/iris/handle/10665/44607
