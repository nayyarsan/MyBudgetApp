import 'package:drift/drift.dart';

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text()(); // checking, savings, credit, cash
  IntColumn get balanceCents => integer().withDefault(const Constant(0))();
  TextColumn get institution => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();
}

class CategoryGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId => integer().references(CategoryGroups, #id)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  BoolColumn get rollover =>
      boolean().withDefault(const Constant(false))();
  IntColumn get goalAmountCents => integer().nullable()();
  DateTimeColumn get goalDate => dateTime().nullable()();
  TextColumn get goalType => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();
}

class MonthlyBudgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId =>
      integer().references(Categories, #id)();
  TextColumn get month => text()(); // YYYY-MM format
  IntColumn get assignedCents =>
      integer().withDefault(const Constant(0))();
  IntColumn get rolledOverCents =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {categoryId, month},
      ];
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  IntColumn get amountCents => integer()();
  TextColumn get payee =>
      text().withLength(min: 0, max: 200)();
  DateTimeColumn get date => dateTime()();
  TextColumn get memo => text().nullable()();
  TextColumn get type => text()(); // income, expense, transfer
  BoolColumn get cleared =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get recurring =>
      boolean().withDefault(const Constant(false))();
  TextColumn get recurringInterval => text().nullable()();
  DateTimeColumn get nextDueDate => dateTime().nullable()();
  TextColumn get importedFrom => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn get toAccountId =>
      integer().nullable().references(Accounts, #id)();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();
}

class NetWorthSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get totalAssetsCents => integer()();
  IntColumn get totalLiabilitiesCents => integer()();
  IntColumn get netWorthCents => integer()();
}

class BudgetSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId =>
      integer().references(Categories, #id)();
  TextColumn get month => text()(); // YYYY-MM
  IntColumn get assignedCents =>
      integer().withDefault(const Constant(0))();
  IntColumn get spentCents =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {categoryId, month},
      ];
}

class PendingRecurringQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sourceTransactionId =>
      integer().references(Transactions, #id)();
  DateTimeColumn get dueDate => dateTime()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
