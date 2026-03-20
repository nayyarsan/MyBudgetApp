# Cloud Sync

## What it does
Bridges local Drift/SQLite data to Firestore for cloud backup. On sync trigger, reads all accounts, category groups, categories, monthly budgets, and transactions from the local DB and batch-writes them to a per-user Firestore document tree. One-directional (local → cloud).

## User actions
- Trigger manual sync from settings
- View last sync timestamp

## Screens and widgets
_none_

## Providers
_none_

## Services
- `lib/features/sync/sync_service.dart`

## Provider chain
Data flows from screen → provider (`sync_providers.dart`) → DAO → Drift table.
Providers are watched reactively; stream-returning DAO methods push updates automatically.

## Data model
| Table | Operations | Reactive? |
| --- | --- | --- |
| accounts | read | yes |
| category_groups | read | yes |
| categories | read | yes |
| monthly_budgets | read | yes |
| transactions | read | yes |

## Dependencies on other features
`accounts`, `budget`, `transactions`

## Known gaps
_none identified_
