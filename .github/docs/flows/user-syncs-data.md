# User Syncs Data to Firestore

## Actor
App user

## Trigger
User taps 'Sync Now' in Settings screen

## Steps
| Step | Action | Screen/Widget | Provider | DAO | Tables written |
| --- | --- | --- | --- | --- | --- |
| 1 | Tap 'Sync Now' | SettingsScreen | syncServiceProvider | _ | _ |
| 2 | Auth check: user must be signed in | _ | SyncService | _ | _ |
| 3 | Read all accounts from local DB | _ | SyncService | AccountsDao.getAllAccounts | accounts |
| 4 | Read all categories from local DB | _ | SyncService | CategoriesDao.getAllCategories | categories |
| 5 | Read all transactions from local DB | _ | SyncService | TransactionsDao.getAllTransactions | transactions |
| 6 | Batch write to Firestore under users/{uid}/... | _ | SyncService (Firestore batch) | _ | _ |
| 7 | Last sync timestamp stored in secure storage | _ | lastSyncProvider | _ | _ |

## Happy path end state
Firestore collections `accounts`, `categoryGroups`, `categories`, `transactions` under `users/{uid}` are overwritten with current local state. `last_sync_timestamp` updated in secure storage.

## Edge cases
- Not signed in: sync returns false, no data written
- Firebase unavailable (offline): Firestore SDK queues writes for later delivery
- Large dataset: Firestore batch limit is 500 operations — may require chunking for large transaction sets
