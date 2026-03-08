import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'recurring_queue_dao.g.dart';

@DriftAccessor(tables: [PendingRecurringQueue, Transactions])
class RecurringQueueDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringQueueDaoMixin {
  RecurringQueueDao(super.db);
}
