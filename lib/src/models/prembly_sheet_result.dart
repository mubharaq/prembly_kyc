import 'package:prembly_kyc/prembly_kyc.dart';

/// The result of the Prembly KYC sheet.
sealed class PremblySheetResult {
  const PremblySheetResult();
}

/// Verification succeeded.
class PremblySheetSuccess extends PremblySheetResult {
  ///
  const PremblySheetSuccess(this.response);

  ///
  final PremblyResponse response;
}

/// Verification failed or an error occurred.
class PremblySheetError extends PremblySheetResult {
  ///
  const PremblySheetError(this.error);

  ///
  final PremblyError error;
}

/// User cancelled the verification.
class PremblySheetCancelled extends PremblySheetResult {
  ///
  const PremblySheetCancelled();
}
