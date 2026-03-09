import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kRolloverKey = 'rollover_global_enabled';
const _storage = FlutterSecureStorage();

/// Global rollover enabled setting (default: false).
final globalRolloverEnabledProvider =
    AsyncNotifierProvider<GlobalRolloverNotifier, bool>(
  GlobalRolloverNotifier.new,
);

class GlobalRolloverNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final val = await _storage.read(key: _kRolloverKey);
    return val == 'true';
  }

  Future<void> setEnabled(bool value) async {
    await _storage.write(
      key: _kRolloverKey,
      value: value.toString(),
    );
    state = AsyncData(value);
  }
}
