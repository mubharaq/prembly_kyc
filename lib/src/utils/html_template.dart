import 'dart:convert';

import 'package:prembly_kyc/prembly_kyc.dart';
import 'package:prembly_kyc/src/utils/constants.dart';

/// Generates the HTML content for the Prembly KYC WebView.
///
/// This creates a minimal HTML page that embeds the Prembly SDK view
/// in an iframe and listens for postMessage events.
String generatePremblyHtml(PremblyConfig config) {
  final metadataJson = config.metadata != null
      ? jsonEncode(config.metadata)
      : '{}';

  return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Identity Verification</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        html, body {
            width: 100%;
            height: 100%;
            overflow: hidden;
            background-color: #ffffff;
        }
        
        #loader {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            background-color: #ffffff;
            z-index: 9999;
        }
        
        .spinner {
            width: 40px;
            height: 40px;
            border: 3px solid #f3f3f3;
            border-top: 3px solid #3b82f6;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }
        
        .loader-text {
            margin-top: 16px;
            color: #6b7280;
            font-size: 14px;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .hidden {
            display: none !important;
        }
    </style>
</head>
<body>
    <div id="loader">
        <div class="spinner"></div>
        <p class="loader-text">Loading verification...</p>
    </div>

    <script src="$premblyWidgetSdkUrl"></script>
    <script>
        function sendToFlutter(type, data) {
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('$jsHandlerName', {
                    type: type,
                    data: data || {}
                });
            }
        }
        
        function hideLoader() {
            document.getElementById('loader').classList.add('hidden');
        }
        
        function handleVerificationResult(response, rawData) {
            console.log('Callback received:', JSON.stringify(response));
            
            if (response.status === 'success' || response.code === '00') {
                sendToFlutter('success', response);
            } else if (response.code === 'E02' || response.status === 'cancelled') {
                sendToFlutter('cancelled', response);
            } else {
                sendToFlutter('error', response);
            }
        }
        
        function startVerification() {
            if (typeof IdentityKYC === 'undefined') {
                setTimeout(startVerification, 100);
                return;
            }
            
            hideLoader();
            
            IdentityKYC.verify({
                widget_id: '${config.widgetId}',
                widget_key: '${config.widgetKey}',
                first_name: '${config.firstName}',
                last_name: '${config.lastName}',
                email: '${config.email}',
                ${config.phone != null ? "phone: '${config.phone}'," : ''}
                metadata: $metadataJson,
                callback: handleVerificationResult
            });
        }
        
        if (document.readyState === 'complete') {
            setTimeout(startVerification, 100);
        } else {
            window.addEventListener('load', function() {
                setTimeout(startVerification, 100);
            });
        }
    </script>
</body>
</html>
''';
}
