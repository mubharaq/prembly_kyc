import 'package:flutter_test/flutter_test.dart';
import 'package:prembly_kyc/prembly_kyc.dart';

void main() {
  group('PremblyKyc', () {
    test('can be instantiated', () {
      const config = PremblyConfig(
        merchantKey: 'key',
        email: 'email',
        firstName: 'first',
        lastName: 'last',
        userRef: 'ref',
        configId: 'example',
      );
      expect(const PremblyKyc(config: config), isNotNull);
    });
  });
}
