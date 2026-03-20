# moneyinsight codebase context

Flutter personal finance app. Riverpod state management. Drift (SQLite) is the
primary database — Firestore is auth + sync only.

**Data flow:** screen (`ConsumerWidget`) → `ref.watch(provider)` → provider function
→ DAO method → Drift table

**Before editing the data layer:** read `lib/core/database/tables.dart` for schemas.

**Key files:**
- `lib/core/database/tables.dart` — all table definitions
- `lib/core/database/daos/` — 6 DAOs (accounts, budget, budget_snapshots, categories, recurring_queue, transactions)
- `lib/features/shell/main_shell.dart` — app navigation
- `lib/features/budget/budget_calculator.dart` — TBB and allocation logic (pure, no DB)
- `lib/features/sync/sync_service.dart` — Firestore sync bridge (local → cloud only)

**Month scoping:** use `selectedMonthProvider` for budget views; pass explicit `DateTime` ranges to DAO methods for other queries.
**Never write to Drift directly from screens** — always go through a provider → DAO.
**Generated files (`*.g.dart`):** never edit manually — run `dart run build_runner build`.
**Account balance:** `balanceCents` is opening balance; running balance = `balanceCents + sum(transactionAmounts)` via `accountRunningBalancesProvider`.

Full architecture docs: `.github/docs/README.md`
Symbol index (providers, DAOs, tables, screens): `.github/docs/symbol_index.md`
