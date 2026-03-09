import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'recurring_queue_dao.g.dart';

@DriftAccessor(tables: [PendingRecurringQueue, Transactions])
class RecurringQueueDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringQueueDaoMixin {
  RecurringQueueDao(super.db);

  Stream<List<PendingRecurringQueueData>> watchPending() =>
      select(pendingRecurringQueue).watch();

  Future<List<PendingRecurringQueueData>> getPending() =>
      select(pendingRecurringQueue).get();

  Future<int> enqueue(PendingRecurringQueueCompanion entry) =>
      into(pendingRecurringQueue).insert(entry);

  Future<void> removeFromQueue(int id) =>
      (delete(pendingRecurringQueue)..where((t) => t.id.equals(id))).go();

  Future<void> clearAll() => delete(pendingRecurringQueue).go();

  Future<bool> isEnqueued(int sourceTransactionId) async {
    final row = await (select(pendingRecurringQueue)
          ..where((t) =>
              t.sourceTransactionId.equals(sourceTransactionId),))
        .getSingleOrNull();
    return row != null;
  }
}
