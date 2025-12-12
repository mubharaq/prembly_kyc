# Prembly Kyc

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

A Flutter widget for [Prembly/IdentityPass](https://prembly.com) KYC verification. Presents a beautiful, Intercom-style draggable bottom sheet with an embedded WebView for seamless identity verification.

## Features

- Automatic camera permission handling
- Clean callback API for success, error, and cancellation
- Automatic widget initialization via Prembly API
- iOS and Android support

## Installation

Add `prembly_kyc` to your `pubspec.yaml`:

```yaml
dependencies:
  prembly_kyc: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Platform Configuration

### Android

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
</manifest>
```

### iOS

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for identity verification</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app may requires access to your location to complete verification</string>
```

## Prerequisites

Before using this package, you need to:

1. Create an account on [Prembly Dashboard](https://dashboard.prembly.com)
2. Create a widget configuration and get your `config_id`
3. Get your API key (`x-api-key`) from the dashboard

## Usage

### Basic Usage

```dart
import 'package:prembly_kyc/prembly_kyc.dart';

// In your widget
ElevatedButton(
  onPressed: () async {
    await PremblyKyc(
      config: PremblyConfig(
        merchantKey: 'your_api_key',
        configId: 'your_widget_config_id',
        email: 'user@example.com',
        firstName: 'John',
        lastName: 'Doe',
        userRef: 'unique_user_123',
      ),
      onSuccess: (response) {
        print('Verified via ${response.channel}');
        print('Data: ${response.data}');
      },
      onError: (error) {
        print('Error: ${error.message}');
        if (error.isPermissionError) {
          // Show permission settings dialog
        }
      },
      onClose: () {
        print('Widget closed');
      },
    ).show(context);
  },
  child: Text('Verify Identity'),
)
```

### With Extra Metadata

You can include additional metadata with the verification:

```dart
PremblyKyc(
  config: PremblyConfig(
    merchantKey: 'your_api_key',
    configId: 'your_widget_config_id',
    email: 'user@example.com',
    firstName: 'John',
    lastName: 'Doe',
    userRef: 'unique_user_123',
    extraMetadata: {
      'account_id': 'ACC123',
      'tier': 'premium',
    },
  ),
  // ...callbacks
).show(context);
```

## API Reference

### PremblyConfig

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `merchantKey` | `String` | Yes | Your Prembly API key (x-api-key) |
| `configId` | `String` | Yes | Widget configuration ID from dashboard |
| `email` | `String` | Yes | User's email address |
| `firstName` | `String` | Yes | User's first name |
| `lastName` | `String` | Yes | User's last name |
| `userRef` | `String` | Yes | Unique reference for the user |
| `extraMetadata` | `Map<String, dynamic>?` | No | Additional data to include |

### PremblyResponse

Returned on successful verification:

| Property | Type | Description |
|----------|------|-------------|
| `status` | `String` | "success" |
| `code` | `String` | "00" for success |
| `message` | `String` | Success message |
| `channel` | `String` | Verification type (e.g., "BVN", "NIN") |
| `data` | `Map<String, dynamic>?` | Verification data |

### PremblyError

Returned on errors:

| Property | Type | Description |
|----------|------|-------------|
| `type` | `PremblyErrorType` | Type of error |
| `message` | `String` | Error message |
| `code` | `String?` | Error code (e.g., "E01", "E02") |
| `isCancelled` | `bool` | Whether user cancelled |
| `isPermissionError` | `bool` | Whether it's a permission issue |

### Error Types

```dart
enum PremblyErrorType {
  cameraPermissionDenied,
  cameraPermissionPermanentlyDenied,
  initializationFailed,
  cancelled,
  verificationFailed,
  networkError,
  webViewError,
  unknown,
}
```

## How It Works

1. **Permission Check**: Requests camera permission if not already granted
2. **Initialization**: Calls Prembly API to initialize the widget and get a `widget_id`
3. **Display**: Shows a modal bottom sheet with the Prembly verification UI
4. **Verification**: User completes the verification flow
5. **Callback**: Returns the result via `onSuccess` or `onError` callbacks

## Handling Permission Errors

When camera permission is permanently denied, you can direct users to settings:

```dart
import 'package:prembly_kyc/prembly_kyc.dart';

onError: (error) {
  if (error.type == PremblyErrorType.cameraPermissionPermanentlyDenied) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Camera Permission Required'),
        content: Text('Please enable camera access in your device settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings(); // From permission_handler package
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }
},
```

## Webhook Integration

For production use, configure your webhook URL in the Prembly dashboard to receive verification results on your backend. This ensures you have a server-side record of all verifications.


## Contributing

Contributions are welcome!

## Credits

Built with ❤️ by [Mubharaq](https://github.com/mubharaq)

[flutter_install_link]: https://docs.flutter.dev/get-started/install
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://pub.dev/packages/very_good_cli
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_ventures_link]: https://verygood.ventures
[very_good_ventures_link_light]: https://verygood.ventures#gh-light-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
