import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:prembly_kyc/src/models/prembly_error.dart';
import 'package:prembly_kyc/src/models/prembly_response.dart';
import 'package:prembly_kyc/src/utils/constants.dart';
import 'package:prembly_kyc/src/utils/html_template.dart';

/// Callback for successful verification.
typedef OnVerificationSuccess = void Function(PremblyResponse response);

/// Callback for verification errors.
typedef OnVerificationError = void Function(PremblyError error);

/// Callback for user cancellation.
typedef OnVerificationCancelled = void Function();

/// A WebView widget that hosts the Prembly KYC verification flow.
class PremblyWebView extends StatefulWidget {
  /// Creates a new [PremblyWebView] instance.
  const PremblyWebView({
    required this.widgetId,
    required this.onSuccess,
    required this.onError,
    required this.onCancelled,
    super.key,
  });

  /// The widget ID returned from the initialization API.
  final String widgetId;

  /// Called when verification succeeds.
  final OnVerificationSuccess onSuccess;

  /// Called when an error occurs.
  final OnVerificationError onError;

  /// Called when the user cancels verification.
  final OnVerificationCancelled onCancelled;

  @override
  State<PremblyWebView> createState() => _PremblyWebViewState();
}

class _PremblyWebViewState extends State<PremblyWebView> {
  InAppWebViewController? _controller;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _controller?.dispose();
    super.dispose();
  }

  void _handleMessage(Map<String, dynamic> message) {
    if (_isDisposed) return;

    final type = message['type'] as String?;
    final data = message['data'] as Map<String, dynamic>? ?? {};

    switch (type) {
      case 'ready':
      case 'loaded':
        // Page ready/loaded - no action needed
        break;

      case 'success':
        final response = PremblyResponse.fromJson(data);
        widget.onSuccess(response);

      case 'cancelled':
        widget.onCancelled();

      case 'error':
        final error = PremblyError.fromJson(data);
        widget.onError(error);

      case 'message':
        // Generic message from iframe, check for known patterns
        _handleGenericMessage(data);

      default:
        if (kDebugMode) {
          print('PremblyKYC: Unknown message type: $type');
        }
    }
  }

  void _handleGenericMessage(Map<String, dynamic> data) {
    // Try to extract status from various possible formats
    final status = data['status'] as String?;
    final code = data['code'] as String?;
    final raw = data['raw'] as String?;
    if (status == 'success' || code == '00') {
      final response = PremblyResponse.fromJson(data);
      widget.onSuccess(response);
    } else if (code == 'E02' || (raw?.contains('cancel') ?? false)) {
      widget.onCancelled();
    } else if (status == 'failed' || code == 'E01') {
      final error = PremblyError.fromJson(data);
      widget.onError(error);
    }
    // Otherwise ignore unknown messages
  }

  @override
  Widget build(BuildContext context) {
    final htmlContent = generatePremblyHtml(widget.widgetId);

    return InAppWebView(
      initialData: InAppWebViewInitialData(
        data: htmlContent,
        encoding: 'utf-8',
        baseUrl: WebUri('https://prembly.com'),
      ),
      initialSettings: InAppWebViewSettings(
        // General settings
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,

        // iOS-specific
        allowsBackForwardNavigationGestures: false,

        // Camera/Media
        allowUniversalAccessFromFileURLs: true,
        allowFileAccessFromFileURLs: true,
      ),
      onWebViewCreated: (controller) {
        _controller = controller;

        // Register JavaScript handler
        controller.addJavaScriptHandler(
          handlerName: jsHandlerName,
          callback: (args) {
            if (args.isNotEmpty && args[0] is Map) {
              _handleMessage(Map<String, dynamic>.from(args[0] as Map));
            }
            return null;
          },
        );
      },
      onPermissionRequest: (controller, request) async {
        // Grant camera/microphone permissions
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
      onLoadStop: (controller, url) {
        // Page finished loading
        if (kDebugMode) {
          print('PremblyKYC: Page loaded - $url');
        }
      },
      onReceivedError: (_, _, error) {
        if (_isDisposed) return;
        widget.onError(
          PremblyError.webViewError(
            'WebView error (${error.type}) - ${error.description}',
          ),
        );
      },
      onReceivedHttpError: (_, _, response) {
        if (_isDisposed) return;
        widget.onError(
          PremblyError.networkError('HTTP ${response.statusCode}'),
        );
      },
      onConsoleMessage: (_, consoleMessage) {
        if (kDebugMode) {
          print('PremblyKYC Console: ${consoleMessage.message}');
        }
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url;
        if (url == null) return NavigationActionPolicy.ALLOW;

        final host = url.host.toLowerCase();

        if (host.contains('prembly') ||
            host.contains('myidentitypass') ||
            host.contains('identitypass') ||
            host.contains('sdk-view') ||
            host.isEmpty) {
          return NavigationActionPolicy.ALLOW;
        }

        // Navigation to external domain = close/callback from Prembly widget
        // Parse query params to determine result
        final queryParams = url.queryParameters;
        final status = queryParams['status']?.toLowerCase();
        final code = queryParams['code'];

        if (status == 'success' || code == '00') {
          widget.onSuccess(
            PremblyResponse(
              status: 'success',
              code: code ?? '00',
              message: queryParams['message'] ?? 'Verification successful',
              channel: queryParams['channel'] ?? '',
              data: queryParams.isNotEmpty
                  ? Map<String, dynamic>.from(queryParams)
                  : null,
            ),
          );
        } else {
          // Treat as cancel/close
          widget.onCancelled();
        }

        return NavigationActionPolicy.CANCEL;
      },
    );
  }
}
