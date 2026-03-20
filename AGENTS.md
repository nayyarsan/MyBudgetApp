# moneyinsight — Agent Instructions

## What this app does
Personal finance app. Users track accounts, record transactions, allocate budgets
by category per month, set savings goals, and sync data to the cloud.

## Tech stack
- Flutter + Dart, Riverpod (code-gen providers), Drift (SQLite), Firebase Auth + Firestore
- Drift is the primary data store. Firestore is sync/backup only.
- State pattern: screen → ConsumerWidget → provider → DAO → Drift table

## Critical files to understand first
- `lib/core/database/tables.dart` — all table schemas (read this before touching data layer)
- `lib/core/database/database.dart` — Drift DB singleton, registers all 6 DAOs
- `lib/main.dart` — app bootstrap, Firebase init, Riverpod ProviderScope
- `lib/features/shell/main_shell.dart` — navigation structure, all top-level routes

## Feature map
| Feature | Screens | Providers | Tables written |
|---------|---------|-----------|----------------|
| accounts | accounts_screen, account_detail_screen, add_account_screen | account_providers.dart | accounts |
| transactions | transactions_screen, add_transaction_screen, import_csv_screen | budget_providers (month scope) | transactions |
| budget | budget_screen | budget_providers, rebalance_provider, recurring_providers | monthly_budgets, budget_snapshots |
| goals | goals_screen, add_goal_screen | goals_providers | categories (goal columns) |
| analytics | analytics_screen, budget_history_screen | analytics_providers, budget_history_providers | — (read only) |
| auth | biometric_lock_screen | auth_providers | — |
| sync | — | — (SyncService) | syncs all tables → Firestore |
| onboarding | onboarding_screen | onboarding_providers | accounts, categories |

## Data model quick reference
| Table | Key columns | Notes |
|-------|------------|-------|
| accounts | id, name, balanceCents, type, institution | soft-delete via isDeleted |
| category_groups | id, name, sortOrder | groups categories for display |
| categories | id, groupId, name, rollover, goalAmountCents, goalDate, goalType | goals stored here |
| monthly_budgets | id, categoryId, month (YYYY-MM), assignedCents, rolledOverCents | envelope allocation |
| transactions | id, accountId, categoryId, amountCents, date, payee, type, recurring | income/expense/transfer |
| net_worth_snapshots | id, date, totalAssetsCents, totalLiabilitiesCents, netWorthCents | periodic snapshots |
| budget_snapshots | id, categoryId, month, assignedCents, spentCents | end-of-month performance |
| pending_recurring_queue | id, sourceTransactionId, dueDate | due recurring transactions |

## Naming conventions
- Providers: `{noun}Provider` — always in `*_providers.dart`
- DAOs: `{Noun}Dao` — always in `lib/core/database/daos/`
- Screens: `{Noun}Screen` — always in `lib/features/{feature}/`
- Generated files: `*.g.dart` — never edit these directly

## Rules for this codebase
- Never write directly to Drift tables from screens — always go through a provider and DAO
- Month scoping: use `selectedMonthProvider` (budget) or pass explicit DateTime ranges to DAO methods
- Sync: `SyncService.syncToFirestore()` in `sync_service.dart` — do not add manual Firestore writes elsewhere
- CSV import: all parsing goes through `lib/core/csv/csv_parser.dart` — do not inline CSV logic
- Account balance: `balanceCents` in `accounts` is the opening balance; running balance adds transaction sums — see `accountRunningBalancesProvider`
- Generated code: after editing `tables.dart` or any `@DriftAccessor`, run `dart run build_runner build --delete-conflicting-outputs`

## Where to look for things
- "How is TBB calculated?" → `lib/features/budget/budget_calculator.dart`
- "How is goal progress calculated?" → `lib/features/goals/goal_calculator.dart`
- "Where is X stored?" → `lib/core/database/tables.dart` then `lib/core/database/daos/`
- "What does screen X watch?" → search for `ref.watch(` in the screen file
- "What triggers sync?" → `lib/features/sync/sync_service.dart`
- "What runs on first launch?" → `lib/features/onboarding/`
- "How does month rollover work?" → `lib/core/services/month_boundary_service.dart`

## Full architecture docs
`.github/docs/README.md`
