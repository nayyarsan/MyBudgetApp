import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [CategoryGroups, Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Future<int> insertGroup(String name) => into(categoryGroups)
      .insert(CategoryGroupsCompanion.insert(name: name));

  Future<int> insertCategory(CategoriesCompanion entry) =>
      into(categories).insert(entry);

  Future<Category?> getCategory(int id) =>
      (select(categories)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Stream<List<Category>> watchCategoriesForGroup(int groupId) =>
      (select(categories)
            ..where(
              (t) =>
                  t.groupId.equals(groupId) &
                  t.isDeleted.equals(false),
            )
            ..orderBy(
              [(t) => OrderingTerm(expression: t.sortOrder)],
            ))
          .watch();

  Stream<List<CategoryGroup>> watchAllGroups() =>
      (select(categoryGroups)
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy(
              [(t) => OrderingTerm(expression: t.sortOrder)],
            ))
          .watch();

  Future<List<Category>> getAllCategories() =>
      (select(categories)..where((t) => t.isDeleted.equals(false)))
          .get();

  Stream<List<Category>> watchCategoriesWithGoals() =>
      (select(categories)
            ..where(
              (t) =>
                  t.isDeleted.equals(false) &
                  t.goalAmountCents.isNotNull(),
            ))
          .watch();

  Future<int> softDeleteCategory(int id) =>
      (update(categories)..where((t) => t.id.equals(id)))
          .write(const CategoriesCompanion(isDeleted: Value(true)));

  Future<void> updateRollover(int categoryId, bool rollover) =>
      (update(categories)..where((t) => t.id.equals(categoryId)))
          .write(CategoriesCompanion(rollover: Value(rollover)));

  Future<void> softDeleteGroup(int id) async {
    await (update(categories)..where((t) => t.groupId.equals(id)))
        .write(const CategoriesCompanion(isDeleted: Value(true)));
    await (update(categoryGroups)..where((t) => t.id.equals(id)))
        .write(const CategoryGroupsCompanion(isDeleted: Value(true)));
  }
}
