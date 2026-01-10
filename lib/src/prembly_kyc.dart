import 'package:flutter/widgets.dart';
import 'package:prembly_kyc/src/config/prembly_config.dart';
import 'package:prembly_kyc/src/models/prembly_error.dart';
import 'package:prembly_kyc/src/models/prembly_response.dart';
import 'package:prembly_kyc/src/models/prembly_sheet_result.dart';
import 'package:prembly_kyc/src/ui/prembly_sheet.dart';
import 'package:prembly_kyc/src/utils/permission_helper.dart';

///
typedef PremblySuccessCallback = void Function(PremblyResponse response);

///
typedef PremblyErrorCallback = void Function(PremblyError error);

///
typedef PremblyCloseCallback = void Function();

/// Prembly KYC widget for identity verification.
///
/// This widget presents a modal bottom sheet containing the Prembly
/// IdentityPass verification flow. It handles camera permissions,
/// WebView lifecycle, and provides callbacks for verification results.
///
/// ## Usage
///
/// ```dart
/// await PremblyKyc(
///   config: PremblyConfig(
///     widgetId: 'your_widget_id',
///     widgetKey: 'your_widget_key',
///     email: 'user@example.com',
///     firstName: 'John',
///     lastName: 'Doe',
///     metadata: {'key': 'value'},
///   ),
///   onSuccess: (response) {
///     print('Verified: ${response.channel}');
///   },
///   onError: (error) {
///     print('Error: ${error.message}');
///   },
///   onClose: () {
///     print('Widget closed');
///   },
/// ).show(context);
/// ```
class PremblyKyc {
  /// Creates a new [PremblyKyc] instance.
  ///
  /// [config] contains the required Prembly configuration.
  /// [onSuccess] is called when verification succeeds.
  /// [onError] is called when an error occurs.
  /// [onClose] is called when the widget is closed (after success, error,
  ///  or cancellation).
  const PremblyKyc({
    required this.config,
    this.onSuccess,
    this.onError,
    this.onClose,
  });

  /// The Prembly configuration.
  final PremblyConfig config;

  /// Called when verification succeeds.
  ///
  /// The [PremblyResponse] contains the verification result and data.
  final PremblySuccessCallback? onSuccess;

  /// Called when an error occurs.
  ///
  /// The [PremblyError] contains details about what went wrong.
  /// This includes permission errors, network errors,
  /// and verification failures.
  final PremblyErrorCallback? onError;

  /// Called when the widget is closed.
  ///
  /// This is called after [onSuccess] or [onError], or when the user
  /// dismisses the widget without completing verification.
  final PremblyCloseCallback? onClose;

  /// Shows the Prembly KYC verification widget.
  ///
  /// This method:
  /// 1. Requests camera and location permission (if not already granted)
  /// 2. Shows the verification sheet
  /// 3. Handles the verification result
  ///
  /// Returns a [Future] that completes when the widget is closed.
  Future<void> show(BuildContext context) async {
    // Check camera permission first
    final permissionResult = await PermissionHelper.requestCameraPermission();
    final locationPermissionResult =
        await PermissionHelper.requestLocationPermission();

    if (permissionResult is PermissionDenied) {
      onError?.call(permissionResult.error);
      onClose?.call();
      return;
    }

    if (locationPermissionResult is PermissionDenied) {
      onError?.call(locationPermissionResult.error);
      onClose?.call();
      return;
    }

    // Show the sheet
    if (!context.mounted) return;

    final result = await showPremblySheet(
      context: context,
      config: config,
    );
    // Handle result
    switch (result) {
      case PremblySheetSuccess(:final response):
        onSuccess?.call(response);
      case PremblySheetError(:final error):
        onError?.call(error);
      case PremblySheetCancelled():
        onError?.call(PremblyError.cancelled());
      case null:
        // User dismissed without result
        break;
    }

    onClose?.call();
  }
}
