import 'package:flutter/foundation.dart';

/// Represents the type of error that occurred during verification.
enum PremblyErrorType {
  /// Camera permission was denied by the user.
  cameraPermissionDenied,

  /// Camera permission is permanently denied (user must enable in settings).
  cameraPermissionPermanentlyDenied,

  /// Widget initialization failed.
  initializationFailed,

  /// The user cancelled the verification process.
  cancelled,

  /// The verification failed.
  verificationFailed,

  /// A network error occurred.
  networkError,

  /// The WebView failed to load.
  webViewError,

  /// An unknown error occurred.
  unknown,
}

/// Represents an error that occurred during the Prembly verification process.
@immutable
class PremblyError implements Exception {
  /// Creates a new [PremblyError] instance.
  const PremblyError({
    required this.type,
    required this.message,
    this.code,
    this.details,
  });

  /// Creates a [PremblyError] from a JSON map (Prembly error response).
  factory PremblyError.fromJson(Map<String, dynamic> json) {
    final code = json['code'] as String?;
    final type = _typeFromCode(code);

    return PremblyError(
      type: type,
      message: json['message'] as String? ?? 'An unknown error occurred',
      code: code,
      details: json,
    );
  }

  /// Creates a camera permission denied error.
  factory PremblyError.cameraPermissionDenied() => const PremblyError(
    type: PremblyErrorType.cameraPermissionDenied,
    message: 'Camera permission is required for identity verification',
  );

  /// Creates a camera permission permanently denied error.
  factory PremblyError.cameraPermissionPermanentlyDenied() => const PremblyError(
    type: PremblyErrorType.cameraPermissionPermanentlyDenied,
    message:
        '''Camera permission is permanently denied. Please enable it in your device settings.''',
  );

  /// Creates a cancellation error.
  factory PremblyError.cancelled() => const PremblyError(
    type: PremblyErrorType.cancelled,
    message: 'Verification was cancelled',
    code: 'E02',
  );

  /// Creates a WebView error.
  factory PremblyError.webViewError(String details) => PremblyError(
    type: PremblyErrorType.webViewError,
    message: 'Failed to load verification widget',
    details: {'error': details},
  );

  /// Creates a network error.
  factory PremblyError.networkError(String details) => PremblyError(
    type: PremblyErrorType.networkError,
    message: 'Network error occurred',
    details: {'error': details},
  );

  /// The type of error.
  final PremblyErrorType type;

  /// A human-readable error message.
  final String message;

  /// The error code from Prembly (if available).
  ///
  /// Common codes:
  /// - "E01": General failure
  /// - "E02": User cancelled
  final String? code;

  /// Additional error details.
  final Map<String, dynamic>? details;

  /// Whether this error indicates the user cancelled the verification.
  bool get isCancelled => type == PremblyErrorType.cancelled || code == 'E02';

  /// Whether this error is related to camera permissions.
  bool get isPermissionError =>
      type == PremblyErrorType.cameraPermissionDenied ||
      type == PremblyErrorType.cameraPermissionPermanentlyDenied;

  static PremblyErrorType _typeFromCode(String? code) {
    return switch (code) {
      'E02' => PremblyErrorType.cancelled,
      'E01' => PremblyErrorType.verificationFailed,
      _ => PremblyErrorType.unknown,
    };
  }

  @override
  String toString() =>
      'PremblyError('
      'type: $type, '
      'message: $message, '
      'code: $code, '
      'details: $details)';
}
