import 'dart:convert';
import 'dart:io';

import 'package:prembly_kyc/src/config/prembly_config.dart';
import 'package:prembly_kyc/src/models/prembly_error.dart';
import 'package:prembly_kyc/src/utils/constants.dart';

/// Result of widget initialization.
sealed class InitializationResult {
  const InitializationResult();
}

/// Successful initialization with widget ID.
class InitializationSuccess extends InitializationResult {
  ///
  const InitializationSuccess(this.widgetId);

  /// The widget ID to use for the verification URL.
  final String widgetId;
}

/// Failed initialization.
class InitializationFailure extends InitializationResult {
  ///
  const InitializationFailure(this.error);

  /// The error that occurred.
  final PremblyError error;
}

/// Client for Prembly API operations.
abstract final class PremblyApiClient {
  static const String _baseUrl = premblyApiBaseUrl;
  static const String _initializePath = '/checker/sdk/widget/initialize';

  /// Initializes the SDK widget for a user.
  ///
  /// Makes a POST request to the Prembly API to get a widget ID
  /// that can be used to load the verification UI.
  static Future<InitializationResult> initializeWidget(
    PremblyConfig config,
  ) async {
    final client = HttpClient();

    try {
      final uri = Uri.parse('$_baseUrl$_initializePath');
      final request = await client.postUrl(uri);

      // Set headers
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('x-api-key', config.merchantKey);

      // Write body
      final body = jsonEncode(config.toRequestBody());
      request.write(body);

      // Get response
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final json = jsonDecode(responseBody) as Map<String, dynamic>;

        if (json['success'] == true) {
          final data = json['data'] as Map<String, dynamic>?;
          final widgetId = data?['widget_id'] as String?;

          if (widgetId != null && widgetId.isNotEmpty) {
            return InitializationSuccess(widgetId);
          }
        }

        // Success was false or widget_id missing
        return InitializationFailure(
          PremblyError(
            type: PremblyErrorType.verificationFailed,
            message: json['detail'] as String? ?? 'Failed to initialize widget',
            code: json['code'] as String?,
          ),
        );
      } else {
        // HTTP error
        Map<String, dynamic>? errorJson;
        try {
          errorJson = jsonDecode(responseBody) as Map<String, dynamic>?;
        } on FormatException catch (_) {
          // Response wasn't JSON
        }

        return InitializationFailure(
          PremblyError(
            type: PremblyErrorType.networkError,
            message:
                errorJson?['detail'] as String? ??
                'HTTP ${response.statusCode}: Failed to initialize',
            code: errorJson?['code'] as String?,
            details: {'statusCode': response.statusCode, 'body': responseBody},
          ),
        );
      }
    } on SocketException catch (e) {
      return InitializationFailure(
        PremblyError.networkError('No internet connection: ${e.message}'),
      );
    } on HttpException catch (e) {
      return InitializationFailure(
        PremblyError.networkError('HTTP error: ${e.message}'),
      );
    } on FormatException catch (e) {
      return InitializationFailure(
        PremblyError(
          type: PremblyErrorType.unknown,
          message: 'Invalid response format: ${e.message}',
        ),
      );
    } finally {
      client.close();
    }
  }
}
