import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoMixin {
  AccountsDao(super.db);

  Future<int> insertAccount(AccountsCompanion entry) =>
      into(accounts).insert(entry);

  Future<Account?> getAccount(int id) =>
      (select(accounts)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Stream<List<Account>> watchAllAccounts() =>
      (select(accounts)
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.name)]))
          .watch();

  Future<List<Account>> getAllAccounts() =>
      (select(accounts)..where((t) => t.isDeleted.equals(false)))
          .get();

  Future<bool> updateAccount(AccountsCompanion entry) =>
      update(accounts).replace(entry);

  Future<int> softDeleteAccount(int id) =>
      (update(accounts)..where((t) => t.id.equals(id)))
          .write(const AccountsCompanion(isDeleted: Value(true)));
}
