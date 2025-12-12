/// Constants used throughout the Prembly KYC package.
library;

/// JavaScript handler name for communication between WebView and Flutter.
const String jsHandlerName = 'PremblyKycHandler';

/// Base URL for the Prembly API.
const String premblyApiBaseUrl = 'https://api.prembly.com';

/// Base URL for the SDK view.
const String premblySdkViewBaseUrl = 'https://sdk-view.prembly.com';

/// Animation duration for the bottom sheet.
const Duration sheetAnimationDuration = Duration(milliseconds: 350);

/// Default sheet height as a fraction of screen height.
const double sheetHeightFraction = 0.9;

/// Corner radius for the bottom sheet.
const double sheetCornerRadius = 16;
