/// Exception thrown when authentication fails
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException({required this.message, this.code});

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when Firestore operations fail
class FirestoreException implements Exception {
  final String message;
  final String? code;

  FirestoreException({required this.message, this.code});

  @override
  String toString() =>
      'FirestoreException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when storage operations fail
class StorageException implements Exception {
  final String message;
  final String? code;

  StorageException({required this.message, this.code});

  @override
  String toString() =>
      'StorageException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when network operations fail
class NetworkException implements Exception {
  final String message;

  NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when validation fails
class ValidationException implements Exception {
  final String message;
  final String? field;

  ValidationException({required this.message, this.field});

  @override
  String toString() =>
      'ValidationException: $message${field != null ? ' (Field: $field)' : ''}';
}

/// Exception thrown when a required permission is denied
class PermissionException implements Exception {
  final String message;
  final String? permission;

  PermissionException({required this.message, this.permission});

  @override
  String toString() =>
      'PermissionException: $message${permission != null ? ' (Permission: $permission)' : ''}';
}

/// Generic application exception
class AppException implements Exception {
  final String message;
  final dynamic originalException;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message';
}
