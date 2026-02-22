import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

const _storage = FlutterSecureStorage();
const _biometricKey = 'biometric_enabled';

final localAuthProvider =
    Provider<LocalAuthentication>((ref) => LocalAuthentication());

/// Whether the user has enabled biometric lock in settings.
final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  final val = await _storage.read(key: _biometricKey);
  return val == 'true';
});

/// Whether the app is currently unlocked (authenticated this session).
final isUnlockedProvider = StateProvider<bool>((ref) => false);

/// Toggle biometric lock on/off and persist the setting.
Future<void> setBiometricEnabled(bool enabled) async {
  await _storage.write(key: _biometricKey, value: enabled.toString());
}
