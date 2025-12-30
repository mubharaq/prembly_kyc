import 'package:flutter/foundation.dart';

/// Configuration for the Prembly KYC widget.
///
/// Contains all required and optional parameters needed to initialize
/// the Prembly IdentityPass verification widget.
@immutable
class PremblyConfig {
  /// Creates a new [PremblyConfig] instance with the required parameters.
  const PremblyConfig({
    required this.widgetId,
    required this.widgetKey,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.metadata,
  });

  /// Your Prembly widget ID.
  ///
  /// Obtain this from your Prembly widget configuration.
  final String widgetId;

  /// Your Prembly widget key.
  ///
  /// Obtain this from your Prembly widget configuration.
  /// Format: wdgt_xxx...
  final String widgetKey;

  /// The user's first name.
  final String firstName;

  /// The user's last name.
  final String lastName;

  /// The user's email address.
  final String email;

  /// The user's phone number (optional).
  final String? phone;

  /// Optional metadata to include with the verification request.
  ///
  /// Can be any additional data you want to associate with this
  /// verification session.
  final Map<String, dynamic>? metadata;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremblyConfig &&
          runtimeType == other.runtimeType &&
          widgetId == other.widgetId &&
          widgetKey == other.widgetKey &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          email == other.email &&
          phone == other.phone &&
          mapEquals(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(
    widgetId,
    widgetKey,
    firstName,
    lastName,
    email,
    phone,
    metadata,
  );

  @override
  String toString() =>
      'PremblyConfig('
      'widgetId: $widgetId, '
      'widgetKey: ${widgetKey.substring(0, 10)}***, '
      'firstName: $firstName, '
      'lastName: $lastName, '
      'email: $email, '
      'phone: $phone, '
      'metadata: $metadata)';
}
