import 'package:flutter/foundation.dart';

/// Represents a successful verification response from Prembly.
@immutable
class PremblyResponse {
  /// Creates a new [PremblyResponse] instance.
  const PremblyResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.channel,
    this.data,
  });

  /// Creates a [PremblyResponse] from a JSON map.
  factory PremblyResponse.fromJson(Map<String, dynamic> json) {
    return PremblyResponse(
      status: json['status'] as String? ?? '',
      code: json['code'] as String? ?? '',
      message: json['message'] as String? ?? '',
      channel: json['channel'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  /// The status of the verification.
  ///
  /// Typically "success" for successful verifications.
  final String status;

  /// The response code.
  ///
  /// "00" indicates success.
  final String code;

  /// A human-readable message describing the result.
  final String message;

  /// The verification channel used.
  ///
  /// Examples: "BVN", "NIN", "PASSPORT", etc.
  final String channel;

  /// The verification data returned from Prembly.
  ///
  /// The structure varies depending on the verification channel.
  /// See Prembly documentation for specific data formats.
  final Map<String, dynamic>? data;

  /// Whether this response indicates a successful verification.
  bool get isSuccess => status.toLowerCase() == 'success' || code == '00';

  /// Converts this response to a JSON map.
  Map<String, dynamic> toJson() => {
        'status': status,
        'code': code,
        'message': message,
        'channel': channel,
        if (data != null) 'data': data,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremblyResponse &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          code == other.code &&
          message == other.message &&
          channel == other.channel &&
          mapEquals(data, other.data);

  @override
  int get hashCode => Object.hash(
        status,
        code,
        message,
        channel,
        data,
      );

  @override
  String toString() => 'PremblyResponse('
      'status: $status, '
      'code: $code, '
      'message: $message, '
      'channel: $channel, '
      'data: $data)';
}
