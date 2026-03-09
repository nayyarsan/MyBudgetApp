import 'package:drift/drift.dart' show Value;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../database/database.dart';

class MonthBoundaryService {
  final AppDatabase db;
  final FlutterSecureStorage storage;

  static const _lastSnapshotKey = 'last_snapshot_month';

  MonthBoundaryService({required this.db, required this.storage});

  /// Returns rollover amount (surplus only, never negative).
  static int computeRolloverCents({
    required int assignedCents,
    required int spentCents,
  }) {
    final surplus = assignedCents - spentCents;
    return surplus > 0 ? surplus : 0;
  }

  /// Returns the next due date for a recurring interval.
  static DateTime computeNextDueDate(DateTime from, String interval) {
    switch (interval) {
      case 'weekly':
        return from.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(from.year, from.month + 1, from.day);
      case 'yearly':
        return DateTime(from.year + 1, from.month, from.day);
      default:
        return DateTime(from.year, from.month + 1, from.day);
    }
  }

  static String _monthKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}';

  /// Main entry point. Call on app startup.
  /// [now] is injectable for testing.
  Future<void> run({DateTime? now}) async {
    final today = now ?? DateTime.now();
    final currentMonth = _monthKey(today);

    final lastSnapshot = await storage.read(key: _lastSnapshotKey);

    if (lastSnapshot == currentMonth) return; // Already ran this month

    final previousMonth = lastSnapshot ??
        _monthKey(DateTime(today.year, today.month - 1));

    await _snapshotMonth(previousMonth);
    await _applyRollovers(previousMonth, currentMonth);
    await _enqueueRecurring(today);

    await storage.write(key: _lastSnapshotKey, value: currentMonth);
  }

  Future<void> _snapshotMonth(String month) async {
    final categories = await db.categoriesDao.getAllCategories();
    final budgets = await db.budgetDao.watchBudgetsForMonth(month).first;

    final parts = month.split('-');
    final start = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    final end = DateTime(start.year, start.month + 1);
    final txList =
        await db.transactionsDao.getTransactionsForMonth(start, end);

    for (final cat in categories) {
      final budget =
          budgets.where((b) => b.categoryId == cat.id).firstOrNull;
      final assigned = budget?.assignedCents ?? 0;

      var spent = 0;
      for (final t in txList) {
        if (t.categoryId == cat.id && t.amountCents < 0) {
          spent += t.amountCents.abs();
        }
      }

      await db.budgetSnapshotsDao.upsertSnapshot(
        BudgetSnapshotsCompanion.insert(
          categoryId: cat.id,
          month: month,
          assignedCents: Value(assigned),
          spentCents: Value(spent),
        ),
      );
    }
  }

  Future<void> _applyRollovers(
    String previousMonth,
    String currentMonth,
  ) async {
    final categories = await db.categoriesDao.getAllCategories();
    final rolloversEnabled = categories.any((c) => c.rollover);
    if (!rolloversEnabled) return;

    final snapshots =
        await db.budgetSnapshotsDao.getSnapshotsForMonth(previousMonth);

    for (final cat in categories) {
      if (!cat.rollover) continue;

      final snapshot =
          snapshots.where((s) => s.categoryId == cat.id).firstOrNull;
      if (snapshot == null) continue;

      final rollover = computeRolloverCents(
        assignedCents: snapshot.assignedCents,
        spentCents: snapshot.spentCents,
      );
      if (rollover == 0) continue;

      final existing = await db.budgetDao.getBudgetForCategoryMonth(
        cat.id,
        currentMonth,
      );
      await db.budgetDao.upsertBudget(
        MonthlyBudgetsCompanion.insert(
          categoryId: cat.id,
          month: currentMonth,
          assignedCents: Value(existing?.assignedCents ?? 0),
          rolledOverCents: Value(rollover),
        ),
      );
    }
  }

  Future<void> _enqueueRecurring(DateTime today) async {
    final allTx = await db.transactionsDao.getAllTransactions();
    final recurringTemplates =
        allTx.where((t) => t.recurring && t.nextDueDate != null).toList();

    for (final tx in recurringTemplates) {
      if (tx.nextDueDate!.isAfter(today)) continue;
      final alreadyQueued =
          await db.recurringQueueDao.isEnqueued(tx.id);
      if (alreadyQueued) continue;

      await db.recurringQueueDao.enqueue(
        PendingRecurringQueueCompanion.insert(
          sourceTransactionId: tx.id,
          dueDate: tx.nextDueDate!,
        ),
      );
    }
  }
}
