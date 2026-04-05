import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'plaid_models.dart';

const _lastSyncKey = 'last_plaid_sync_date';

class PlaidFetchResult {
  final bool connected;
  final List<PlaidTransaction> transactions;
  final List<PlaidAccount> accounts;

  const PlaidFetchResult({
    required this.connected,
    required this.transactions,
    required this.accounts,
  });
}

class PlaidService {
  final FirebaseFunctions _functions;
  final FlutterSecureStorage _storage;

  StreamSubscription? _successSub;
  StreamSubscription? _exitSub;

  PlaidService({
    FirebaseFunctions? functions,
    FlutterSecureStorage? storage,
  })  : _functions = functions ?? FirebaseFunctions.instance,
        _storage = storage ?? const FlutterSecureStorage();

  /// Opens Plaid Link and exchanges the public token for an access token.
  /// The access token is stored in Firestore by the Cloud Function — never returned here.
  Future<void> connectAccount({
    required void Function() onSuccess,
    required void Function(String reason) onExit,
  }) async {
    // Cancel any stale listeners from a previous attempt
    _successSub?.cancel();
    _exitSub?.cancel();

    final result =
        await _functions.httpsCallable('createLinkToken').call<Map>({});
    final linkToken = result.data['linkToken'] as String;

    final config = LinkTokenConfiguration(token: linkToken);

    _successSub = PlaidLink.onSuccess.listen((event) async {
      _successSub?.cancel();
      _exitSub?.cancel();
      await _functions.httpsCallable('exchangeToken').call<Map>({
        'publicToken': event.publicToken,
      });
      onSuccess();
    });

    _exitSub = PlaidLink.onExit.listen((event) {
      _successSub?.cancel();
      _exitSub?.cancel();
      onExit(event.error?.displayMessage ?? 'cancelled');
    });

    await PlaidLink.create(configuration: config);
    await PlaidLink.open();
  }

  /// Fetches transactions from Plaid since the last sync date.
  /// Returns empty result if no Plaid account is connected.
  Future<PlaidFetchResult> fetchTransactions() async {
    final sinceDate = await _storage.read(key: _lastSyncKey);

    final result = await _functions
        .httpsCallable('fetchTransactions')
        .call<Map>({'since': sinceDate});

    final data = result.data as Map;
    final connected = data['connected'] as bool? ?? false;

    if (!connected) {
      return const PlaidFetchResult(
        connected: false,
        transactions: [],
        accounts: [],
      );
    }

    final rawTransactions = (data['transactions'] as List)
        .cast<Map<String, dynamic>>();
    final rawAccounts = (data['accounts'] as List)
        .cast<Map<String, dynamic>>();

    return PlaidFetchResult(
      connected: true,
      transactions: rawTransactions
          .map(PlaidTransaction.fromJson)
          .toList(),
      accounts: rawAccounts
          .map(PlaidAccount.fromJson)
          .toList(),
    );
  }

  /// Saves today's date as the last sync marker.
  Future<void> markSyncComplete() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await _storage.write(key: _lastSyncKey, value: today);
  }

  /// Clears the last sync date and revokes Plaid access via Cloud Function.
  Future<void> disconnect() async {
    try {
      await _functions.httpsCallable('revokeToken').call<Map>({});
    } catch (e) {
      debugPrint('PlaidService.disconnect: revokeToken error: $e');
    }
    await _storage.delete(key: _lastSyncKey);
  }
}
