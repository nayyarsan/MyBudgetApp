import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/database/providers.dart';

/// Watches the pending recurring queue.
final pendingRecurringProvider =
    StreamProvider<List<PendingRecurringQueueData>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.recurringQueueDao.watchPending();
});
