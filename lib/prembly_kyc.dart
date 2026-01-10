/// Prembly KYC - A Flutter widget for Prembly/IdentityPass verification.
///
/// This package provides a simple way to integrate Prembly's identity
/// verification widget into your Flutter application.
///
/// ## Getting Started
///
/// Add the package to your `pubspec.yaml`:
///
/// ```yaml
/// dependencies:
///   prembly_kyc: ^0.1.0
/// ```
///
/// ## Usage
///
/// ```dart
/// import 'package:prembly_kyc/prembly_kyc.dart';
///
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
///     print('Verified via ${response.channel}');
///   },
///   onError: (error) {
///     print('Error: ${error.message}');
///   },
/// ).show(context);
/// ```
///
/// ## Permissions
///
/// This package requires camera permission for identity verification.
/// Add the following to your platform configurations:
///
/// ### Android (AndroidManifest.xml)
///
/// ```xml
/// <uses-permission android:name="android.permission.INTERNET" />
/// <uses-permission android:name="android.permission.CAMERA" />
/// <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
/// <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
/// ```
///
/// ### iOS (Info.plist)
///
/// ```xml
/// <key>NSCameraUsageDescription</key>
/// <string>Camera access is required for identity verification</string>
/// <key>NSLocationWhenInUseUsageDescription</key>
/// <string>Location access is required for identity verification</string>
/// <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
/// <string>Allow access to your phone's location for verification</string>
/// ```
library;

export 'src/config/prembly_config.dart';
export 'src/models/prembly_error.dart';
export 'src/models/prembly_response.dart';
export 'src/prembly_kyc.dart';
