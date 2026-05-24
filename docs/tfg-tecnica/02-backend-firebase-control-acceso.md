# Documento 02 - Backend Firebase y Control de Acceso

Estado: Borrador
Responsable: Firebase Backend Security Agent

## 1. Objetivo
Definir la arquitectura backend en Firebase y demostrar el modelo de autorización aplicado.

## 2. Modelo de datos
### 2.1 Colecciones y subcolecciones
### 2.2 Campos principales
### 2.3 Indices y consultas relevantes

## 3. Autenticación y autorización
### 3.1 Auth (metodos y restricciones)
### 3.2 Matriz de acceso por recurso y operación
### 3.3 Principio de minimo privilegio

## 4. Reglas de seguridad
### 4.1 Firestore Rules
### 4.2 Storage Rules
### 4.3 Casos permitidos y denegados

## 5. Verificación técnica
- Estrategia de pruebas de reglas.
- Resultados resumidos.
- Riesgo residual.

## 6. Evidencias
- [firestore.rules](../../firestore.rules)
- [storage.rules](../../storage.rules)
- [firestore.indexes.json](../../firestore.indexes.json)
- [security-validation-tests.md](../../.github/firebase/security-validation-tests.md)
