import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricCredentials {
  const BiometricCredentials({required this.email, required this.password});

  final String email;
  final String password;
}

class BiometricAuthService {
  BiometricAuthService._();

  static final BiometricAuthService instance = BiometricAuthService._();

  static const _emailKey = 'biometric_auth_email';
  static const _passwordKey = 'biometric_auth_password';

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<bool> isAvailable() async {
    try {
      return await _localAuth.isDeviceSupported() &&
          await _localAuth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({required String localizedReason}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    await _secureStorage.write(key: _emailKey, value: email);
    await _secureStorage.write(key: _passwordKey, value: password);
  }

  Future<BiometricCredentials?> getCredentials() async {
    final email = await _secureStorage.read(key: _emailKey);
    final password = await _secureStorage.read(key: _passwordKey);
    if (email == null || email.isEmpty || password == null || password.isEmpty) {
      return null;
    }
    return BiometricCredentials(email: email, password: password);
  }

  Future<bool> hasCredentials() async {
    return await getCredentials() != null;
  }

  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _emailKey);
    await _secureStorage.delete(key: _passwordKey);
  }
}