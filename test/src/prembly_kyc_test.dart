import 'package:flutter_test/flutter_test.dart';
import 'package:prembly_kyc/prembly_kyc.dart';

void main() {
  group('PremblyKyc', () {
    test('can be instantiated', () {
      const config = PremblyConfig(
        widgetKey: 'key',
        email: 'email',
        firstName: 'first',
        lastName: 'last',
        widgetId: 'example',
      );
      expect(const PremblyKyc(config: config), isNotNull);
    });
  });
}
