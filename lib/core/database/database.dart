import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import 'daos/accounts_dao.dart';
import 'daos/categories_dao.dart';
import 'daos/transactions_dao.dart';
import 'daos/budget_dao.dart';
import 'daos/budget_snapshots_dao.dart';
import 'daos/recurring_queue_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Accounts,
    CategoryGroups,
    Categories,
    MonthlyBudgets,
    Transactions,
    NetWorthSnapshots,
    BudgetSnapshots,
    PendingRecurringQueue,
  ],
  daos: [
    AccountsDao,
    CategoriesDao,
    TransactionsDao,
    BudgetDao,
    BudgetSnapshotsDao,
    RecurringQueueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(transactions, transactions.toAccountId);
      }
      if (from < 3) {
        await m.addColumn(transactions, transactions.nextDueDate);
        await m.addColumn(monthlyBudgets, monthlyBudgets.rolledOverCents);
        await m.createTable(budgetSnapshots);
        await m.createTable(pendingRecurringQueue);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'moneyinsight.db'));
    return NativeDatabase(file);
  });
}
