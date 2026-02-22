import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Future<int> insertTransaction(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  Future<Transaction?> getTransaction(int id) =>
      (select(transactions)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Stream<List<Transaction>> watchTransactionsForMonth(
    int year,
    int month,
  ) {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    return (select(transactions)
          ..where(
            (t) =>
                t.isDeleted.equals(false) &
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerThanValue(end),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<List<Transaction>> getTransactionsForMonth(
    DateTime start,
    DateTime end,
  ) =>
      (select(transactions)
            ..where(
              (t) =>
                  t.isDeleted.equals(false) &
                  t.date.isBiggerOrEqualValue(start) &
                  t.date.isSmallerThanValue(end),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Future<List<Transaction>> getTransactionsForAccount(
    int accountId,
  ) =>
      (select(transactions)
            ..where(
              (t) =>
                  t.accountId.equals(accountId) &
                  t.isDeleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Future<int> softDelete(int id) =>
      (update(transactions)..where((t) => t.id.equals(id)))
          .write(const TransactionsCompanion(isDeleted: Value(true)));
}
