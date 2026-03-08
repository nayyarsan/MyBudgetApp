import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../database/providers.dart';
import 'month_boundary_service.dart';

final monthBoundaryServiceProvider = Provider<MonthBoundaryService>((ref) {
  final db = ref.watch(databaseProvider);
  const storage = FlutterSecureStorage();
  return MonthBoundaryService(db: db, storage: storage);
});
