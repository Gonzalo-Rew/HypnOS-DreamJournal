import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';

/// Maps an [AuthException] semantic code to the localized user-facing string.
/// Falls back to [l.authErrorGeneric] for unrecognised codes.
String localizeAuthError(AppLocalizations l, String? code) {
  return switch (code) {
    'email-already-in-use' => l.authErrorEmailInUse,
    'invalid-email' => l.authErrorInvalidEmail,
    'weak-password' => l.authErrorWeakPassword,
    // Firebase uses 'wrong-password' for older SDK; 'invalid-credential' for newer
    'wrong-password' || 'invalid-credential' => l.authErrorWrongPassword,
    'user-not-found' => l.authErrorUserNotFound,
    'user-disabled' => l.authErrorUserDisabled,
    'too-many-requests' => l.authErrorTooManyRequests,
    'network-request-failed' => l.authErrorNetworkFailed,
    'operation-not-allowed' => l.authErrorOperationNotAllowed,
    'google-failed' => l.authErrorGoogleFailed,
    'apple-failed' => l.authErrorAppleFailed,
    'apple-not-supported' => l.authErrorAppleNotSupported,
    'apple-not-interactive' => l.authErrorAppleNotInteractive,
    _ => l.authErrorGeneric,
  };
}
