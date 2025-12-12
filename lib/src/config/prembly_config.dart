import 'package:flutter/foundation.dart';

/// Configuration for the Prembly KYC widget.
///
/// Contains all required and optional parameters needed to initialize
/// the Prembly IdentityPass verification widget.
@immutable
class PremblyConfig {
  /// Creates a new [PremblyConfig] instance.
  ///
  /// [merchantKey] is your Prembly public key (required).
  /// [email] is the user's email address (required).
  /// [firstName] is the user's first name (required).
  /// [lastName] is the user's last name (required).
  /// [userRef] is a unique reference for the user (required).
  /// [configId] is the widget configuration ID from your dashboard (optional).
  const PremblyConfig({
    required this.merchantKey,
    required this.configId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userRef,
    this.extraMetadata,
  });

  /// Your Prembly merchant public key.
  ///
  /// Obtain this from your Prembly dashboard settings.
  final String merchantKey;

  /// The widget configuration ID from your Prembly dashboard.
  ///
  /// This is returned when you create a widget on the dashboard.
  final String configId;

  /// The user's email address.
  final String email;

  /// The user's first name.
  final String firstName;

  /// The user's last name.
  final String lastName;

  /// A unique reference identifier for the user.
  ///
  /// This should be unique per verification attempt and is used
  /// to track the verification in your system.
  final String userRef;

  /// Optional extra metadata to include with the initialization request.
  ///
  /// Can be any additional data you want to associate with this
  /// verification session.
  final Map<String, dynamic>? extraMetadata;

  /// Converts the config to the request body for initialization.
  Map<String, dynamic> toRequestBody() => {
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'user_ref': userRef,
    'config_id': configId,
    if (extraMetadata != null) 'extra_metadata': extraMetadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremblyConfig &&
          runtimeType == other.runtimeType &&
          merchantKey == other.merchantKey &&
          configId == other.configId &&
          email == other.email &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          userRef == other.userRef &&
          mapEquals(extraMetadata, other.extraMetadata);

  @override
  int get hashCode => Object.hash(
    merchantKey,
    configId,
    email,
    firstName,
    lastName,
    userRef,
    extraMetadata,
  );

  @override
  String toString() =>
      'PremblyConfig('
      'merchantKey: ${merchantKey.substring(0, 8)}***, '
      'configId: $configId, '
      'email: $email, '
      'firstName: $firstName, '
      'lastName: $lastName, '
      'userRef: $userRef, '
      'extraMetadata: $extraMetadata)';
}
