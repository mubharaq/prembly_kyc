import 'package:permission_handler/permission_handler.dart';
import 'package:prembly_kyc/src/models/prembly_error.dart';

///
sealed class PermissionResult {
  const PermissionResult();
}

///
class PermissionGranted extends PermissionResult {
  ///
  const PermissionGranted();
}

///
class PermissionDenied extends PermissionResult {
  ///
  const PermissionDenied(this.error);

  ///
  final PremblyError error;
}

/// Handles permission requests for the KYC verification.
abstract final class PermissionHelper {
  /// Requests camera permission and returns the result.
  ///
  /// This method first checks the current permission status.
  /// If not determined, it requests permission from the user.
  /// Returns [PermissionGranted] if access is allowed, or
  /// [PermissionDenied] with an appropriate error otherwise.
  static Future<PermissionResult> requestCameraPermission() async {
    var status = await Permission.camera.status;

    // If not determined yet, request permission
    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isGranted || status.isLimited) {
      return const PermissionGranted();
    }

    if (status.isPermanentlyDenied) {
      return PermissionDenied(
        PremblyError.cameraPermissionPermanentlyDenied(),
      );
    }

    return PermissionDenied(
      PremblyError.cameraPermissionDenied(),
    );
  }

  /// Requests location permission and returns the result.
  ///
  /// This method first checks the current permission status.
  /// If not determined, it requests permission from the user.
  /// Returns [PermissionGranted] if access is allowed, or
  /// [PermissionDenied] with an appropriate error otherwise.
  static Future<PermissionResult> requestLocationPermission() async {
    var status = await Permission.location.status;

    // If not determined yet, request permission
    if (status.isDenied) {
      status = await Permission.location.request();
    }

    if (status.isGranted || status.isLimited) {
      return const PermissionGranted();
    }

    return PermissionDenied(
      PremblyError.locationPermissionDenied(),
    );
  }

  /// Opens the app settings page.
  ///
  /// Useful when camera permission is permanently denied and the user
  /// needs to manually enable it.
  static Future<bool> openSettings() => openAppSettings();
}
