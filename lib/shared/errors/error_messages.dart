import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hypnos_dreamjournal/shared/errors/exceptions.dart';

/// Centralised error-to-message mapper.
///
/// Usage:
///   // Log technical detail + get friendly string in one call:
///   final msg = AppError.handle(e, 'DreamForm.update');
///   setState(() => _errorMessage = msg);
///
/// Rules:
///   - [handle] always calls [debugPrint] with the raw error.
///   - The returned string is never technical; it never exposes exception types,
///     stack traces, Firebase codes, or server responses.
class AppError {
  AppError._();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Logs [e] under [context] and returns a user-friendly string.
  static String handle(Object e, String context, [StackTrace? st]) {
    debugPrint('[$context] Error: $e${st != null ? '\n$st' : ''}');
    return _friendly(e);
  }

  // ── Mapping logic ─────────────────────────────────────────────────────────

  static String _friendly(Object e) {
    // Typed app exceptions — messages already curated at creation site.
    if (e is AuthException) return e.message;
    if (e is ValidationException) return e.message;
    if (e is PermissionException) {
      return 'Permiso denegado. Revisa los permisos de la app en Ajustes.';
    }
    if (e is NetworkException) {
      return 'Sin conexión. Revisa tu conexión a internet.';
    }
    if (e is StorageException) {
      return 'No se pudo subir el archivo. Inténtalo de nuevo.';
    }
    if (e is FirestoreException) {
      return _fromCode(e.code);
    }
    if (e is AppException) return e.message;

    // Firebase SDK exceptions.
    if (e is FirebaseException) return _fromCode(e.code);

    // Generic heuristics on message text as last resort.
    final msg = e.toString().toLowerCase();
    if (msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection') ||
        msg.contains('reach') ||
        msg.contains('timeout')) {
      return 'Sin conexión. Revisa tu conexión a internet.';
    }
    if (msg.contains('permission') || msg.contains('denied')) {
      return 'No tienes permiso para realizar esta acción.';
    }
    if (msg.contains('not-found') || msg.contains('not found')) {
      return 'El recurso no existe o fue eliminado.';
    }
    return 'Algo salió mal. Inténtalo de nuevo.';
  }

  static String _fromCode(String? code) {
    return switch (code) {
      'permission-denied' => 'No tienes permiso para esta acción.',
      'unavailable' ||
      'deadline-exceeded' => 'Servicio no disponible. Inténtalo más tarde.',
      'not-found' => 'El recurso no existe o fue eliminado.',
      'already-exists' => 'Ya existe un registro con estos datos.',
      'resource-exhausted' => 'Límite de uso alcanzado. Inténtalo más tarde.',
      'unauthenticated' => 'Sesión expirada. Vuelve a iniciar sesión.',
      _ => 'Algo salió mal. Inténtalo de nuevo.',
    };
  }
}
