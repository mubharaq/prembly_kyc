import 'package:prembly_kyc/src/utils/constants.dart';

/// Generates the HTML content for the Prembly KYC WebView.
///
/// This creates a minimal HTML page that embeds the Prembly SDK view
/// in an iframe and listens for postMessage events.
String generatePremblyHtml(String widgetId) {
  final sdkUrl = '$premblySdkViewBaseUrl/$widgetId';

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
        
        iframe {
            width: 100%;
            height: 100%;
            border: none;
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
    
    <iframe 
        id="prembly-frame" 
        src="$sdkUrl"
        allow="camera; microphone; geolocation"
        allowfullscreen
    ></iframe>

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
        
        // Listen for messages from the iframe
        window.addEventListener('message', function(event) {
            // Verify origin is from Prembly
            if (!event.origin.includes('prembly') && !event.origin.includes('sdk-view')) {
                return;
            }
            
            var data = event.data;
            
            // Handle different message formats
            if (typeof data === 'string') {
                try {
                    data = JSON.parse(data);
                } catch (e) {
                    // Not JSON, might be a simple string message
                    sendToFlutter('message', { raw: data });
                    return;
                }
            }
            
            if (!data) return;
            
            // Normalize the response
            var status = data.status || '';
            var code = data.code || '';
            
            if (status === 'success' || code === '00') {
                sendToFlutter('success', data);
            } else if (code === 'E02' || status === 'cancelled' || data.message === 'Verification Canceled') {
                sendToFlutter('cancelled', data);
            } else if (status === 'failed' || status === 'error' || code === 'E01') {
                sendToFlutter('error', data);
            } else {
                // Unknown message, forward it anyway
                sendToFlutter('message', data);
            }
        });
        
        // Handle iframe load
        var iframe = document.getElementById('prembly-frame');
        iframe.onload = function() {
            hideLoader();
            sendToFlutter('loaded', { success: true });
        };
        
        iframe.onerror = function(error) {
            sendToFlutter('error', {
                code: 'IFRAME_LOAD_ERROR',
                message: 'Failed to load verification page'
            });
        };
        
        // Notify Flutter when page is ready
        sendToFlutter('ready', { timestamp: Date.now() });
    </script>
</body>
</html>
''';
}
