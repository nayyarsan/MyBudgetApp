import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:moneyinsight/core/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting();
  });

  tearDown(() async {
    await db.close();
  });

  test('can insert and retrieve an account', () async {
    final id = await db.accountsDao.insertAccount(
      AccountsCompanion.insert(
        name: 'Checking',
        type: 'checking',
        balanceCents: const Value(100000),
        institution: const Value('Chase'),
      ),
    );
    final account = await db.accountsDao.getAccount(id);
    expect(account?.name, 'Checking');
    expect(account?.balanceCents, 100000);
  });

  test('can insert and retrieve a category group and category', () async {
    final groupId = await db.categoriesDao.insertGroup('Housing');
    final catId = await db.categoriesDao.insertCategory(
      CategoriesCompanion.insert(
        groupId: groupId,
        name: 'Rent',
      ),
    );
    final cat = await db.categoriesDao.getCategory(catId);
    expect(cat?.name, 'Rent');
    expect(cat?.groupId, groupId);
  });

  test('amounts stored as integer cents to avoid float errors', () async {
    // First need an account
    final accountId = await db.accountsDao.insertAccount(
      AccountsCompanion.insert(name: 'Test', type: 'checking'),
    );
    final id = await db.transactionsDao.insertTransaction(
      TransactionsCompanion.insert(
        accountId: accountId,
        amountCents: -4999, // -$49.99
        payee: 'Grocery Store',
        date: DateTime(2026, 2, 21),
        type: 'expense',
      ),
    );
    final tx = await db.transactionsDao.getTransaction(id);
    expect(tx?.amountCents, -4999);
  });

  test('monthly budget upsert works', () async {
    final groupId = await db.categoriesDao.insertGroup('Food');
    final catId = await db.categoriesDao.insertCategory(
      CategoriesCompanion.insert(groupId: groupId, name: 'Groceries'),
    );
    await db.budgetDao.upsertBudget(
      MonthlyBudgetsCompanion.insert(
        categoryId: catId,
        month: '2026-02',
        assignedCents: const Value(50000),
      ),
    );
    final budgets = await db.budgetDao.watchBudgetsForMonth('2026-02').first;
    expect(budgets.length, 1);
    expect(budgets.first.assignedCents, 50000);
  });
}
