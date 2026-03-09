import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/database/database.dart';
import '../../core/database/providers.dart';

const _lastSyncKey = 'last_sync_timestamp';
const _storage = FlutterSecureStorage();

/// ISO-8601 timestamp of the last successful sync, or null if never synced.
final lastSyncProvider = FutureProvider<DateTime?>((ref) async {
  final val = await _storage.read(key: _lastSyncKey);
  if (val == null) return null;
  return DateTime.tryParse(val);
});

class SyncService {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SyncService({
    required AppDatabase db,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = db,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Returns true on success, false if the user is not authenticated or
  /// Firebase is unavailable.
  Future<bool> syncToFirestore() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    try {
      final userDoc = _firestore.collection('users').doc(uid);
      final batch = _firestore.batch();

      // --- Accounts ---
      final accounts = await _db.accountsDao.getAllAccounts();
      for (final a in accounts) {
        final ref = userDoc.collection('accounts').doc(a.id.toString());
        batch.set(ref, {
          'name': a.name,
          'type': a.type,
          'balanceCents': a.balanceCents,
          'institution': a.institution,
          'isDeleted': a.isDeleted,
          'updatedAt': a.updatedAt.toIso8601String(),
        });
      }

      // --- Category groups ---
      final groups = await _db.categoriesDao.watchAllGroups().first;
      for (final g in groups) {
        final ref =
            userDoc.collection('categoryGroups').doc(g.id.toString());
        batch.set(ref, {
          'name': g.name,
          'sortOrder': g.sortOrder,
          'isDeleted': g.isDeleted,
        });
      }

      // --- Categories ---
      final cats = await _db.categoriesDao.getAllCategories();
      for (final c in cats) {
        final ref = userDoc.collection('categories').doc(c.id.toString());
        batch.set(ref, {
          'groupId': c.groupId,
          'name': c.name,
          'rollover': c.rollover,
          'goalAmountCents': c.goalAmountCents,
          'goalDate': c.goalDate?.toIso8601String(),
          'goalType': c.goalType,
          'isDeleted': c.isDeleted,
        });
      }

      // --- Transactions ---
      final txs = await _db.transactionsDao.getAllTransactions();
      for (final t in txs) {
        final ref =
            userDoc.collection('transactions').doc(t.id.toString());
        batch.set(ref, {
          'accountId': t.accountId,
          'categoryId': t.categoryId,
          'amountCents': t.amountCents,
          'payee': t.payee,
          'date': t.date.toIso8601String(),
          'memo': t.memo,
          'type': t.type,
          'cleared': t.cleared,
          'isDeleted': t.isDeleted,
        });
      }

      await batch.commit();
      await _storage.write(
        key: _lastSyncKey,
        value: DateTime.now().toIso8601String(),
      );
      return true;
    } catch (e) {
      debugPrint('Firestore sync failed: $e');
      return false;
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncService(db: db);
});
