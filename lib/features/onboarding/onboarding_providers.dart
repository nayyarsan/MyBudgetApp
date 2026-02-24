import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kOnboardingKey = 'onboarding_complete';
const _kMonthlyIncomeKey = 'monthly_income_cents';

final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final val = await const FlutterSecureStorage().read(key: _kOnboardingKey);
  return val == 'true';
});

Future<void> setOnboardingComplete() async {
  await const FlutterSecureStorage().write(
    key: _kOnboardingKey,
    value: 'true',
  );
}

Future<void> saveMonthlyIncome(int cents) async {
  await const FlutterSecureStorage().write(
    key: _kMonthlyIncomeKey,
    value: cents.toString(),
  );
}
