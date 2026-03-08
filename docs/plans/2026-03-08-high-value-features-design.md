# High-Value Features Design
**Date:** 2026-03-08
**Approach:** Option B — Shared Infrastructure First

---

## Overview

Four features built around a shared `MonthBoundaryService` that runs on app start and handles all month-transition logic:

1. Recurring Transactions (schema-ready, needs UI + logic)
2. Budget Rollover (schema-ready, needs logic + UI)
3. Budget Rebalancing (new feature)
4. Budget History (new feature)

---

## Architecture

### MonthBoundaryService

Runs on app start. Checks `last_snapshot_month` in SecureStorage against current month. If a new month has begun:

1. **Snapshot** — writes `BudgetSnapshot` per category for the closing month (assigned + spent)
2. **Rollover** — for categories with `rollover=true`, computes prior month's available balance and seeds the new month's `MonthlyBudget` with `rolledOverCents`
3. **Recurring queue** — for each recurring transaction where `nextDueDate <= today`, inserts into `PendingRecurringQueue`
4. Updates `last_snapshot_month` in SecureStorage

### New Database Tables

#### `BudgetSnapshots`
| Column | Type | Notes |
|--------|------|-------|
| id | int PK | autoincrement |
| categoryId | int FK | → Categories.id |
| month | text | YYYY-MM format |
| assignedCents | int | budget assigned that month |
| spentCents | int | actual spending that month |
| createdAt | datetime | |

Unique constraint: `(categoryId, month)`

#### `PendingRecurringQueue`
| Column | Type | Notes |
|--------|------|-------|
| id | int PK | autoincrement |
| sourceTransactionId | int FK | → Transactions.id (the recurring template) |
| dueDate | datetime | when this occurrence is due |
| createdAt | datetime | |

---

## Feature Details

### 1. Recurring Transactions

**Schema fields (already exist):**
- `Transactions.recurring` (bool, default false)
- `Transactions.recurringInterval` (text, nullable): `weekly` | `monthly` | `yearly`

**New field needed:**
- `Transactions.nextDueDate` (datetime, nullable) — tracks when next occurrence is due

**Logic:**
- On save of a recurring transaction, compute and store `nextDueDate`
- `MonthBoundaryService` (and app start check) enqueues transactions where `nextDueDate <= today`
- On user confirmation: clone transaction with new date, advance `nextDueDate` on template

**UI — Add/Edit Transaction Screen:**
- "Repeats" toggle
- When on: dropdown with Weekly / Monthly / Yearly

**UI — Budget Screen Banner:**
- Dismissible banner: "N recurring transactions due — Review"
- Taps open bottom sheet: list of pending items, each with Confirm / Skip
- "Confirm All" button at bottom

---

### 2. Budget Rollover

**Schema fields (already exist):**
- `Categories.rollover` (bool, default false)

**New field needed:**
- `MonthlyBudgets.rolledOverCents` (int, default 0) — stores the carried-over amount

**Logic:**
```
rolledOverCents = max(0, previousMonth.assignedCents - previousMonth.spentCents)
```
Overspending does NOT carry forward as negative debt — only surplus rolls over.

`BudgetCalculator.available()` already accepts `rolledOverCents` and `rollover` — just needs real values instead of hardcoded 0.

**Global setting:** `rollover_global_enabled` in SecureStorage (default: false)
**Per-category override:** `Categories.rollover` field

**UI — Settings Screen:**
- "Roll over unused budget" toggle (global default)

**UI — Category Edit Sheet:**
- Per-category rollover override toggle, visible only when global rollover is enabled

---

### 3. Budget Rebalancing

**Logic:**
```
overages = categories where spentCents > assignedCents (sorted by deficit, largest first)
surplus = categories where availableCents > 0 (sorted by surplus, largest first)

For each overage:
  pull proportionally from surplus pool
  → generate list of suggested MonthlyBudget patches

Patches are NOT applied until user approves.
```

**UI — Budget Screen:**
- "Rebalance" button in app bar (only visible when any category is overspent)
- Opens bottom sheet:
  - Overspent categories (red) with deficit amount
  - Suggested source categories (green) with proposed reduction
  - "Approve" applies all patches; user can adjust individual amounts before approving

---

### 4. Budget History

**Data source:** `BudgetSnapshots` table (written by `MonthBoundaryService` on month close)

**UI — Analytics Screen (new third tab):**
- Tab label: "Budget History"
- Summary line chart at top: total assigned vs total spent per month (last 6–12 months)
- Scrollable list of past months below chart
- Each month expandable to show per-category table:

| Category | Assigned | Spent | Variance |
|----------|----------|-------|----------|
| Groceries | $400 | $380 | +$20 |
| Dining | $150 | $210 | -$60 |

Variance is color-coded: green (under), red (over), grey (zero).

---

## New Riverpod Providers

| Provider | Type | Role |
|----------|------|------|
| `pendingRecurringProvider` | StreamProvider | Watches PendingRecurringQueue |
| `rolloverAmountsProvider` | FutureProvider | Computes prior month surplus per category |
| `budgetHistoryProvider` | FutureProvider | Queries BudgetSnapshots grouped by month |
| `rebalanceSuggestionsProvider` | Provider | Detects overages, proposes patches |
| `globalRolloverEnabledProvider` | StateProvider | Reads/writes global rollover setting |

---

## Files to Create

- `lib/core/services/month_boundary_service.dart`
- `lib/core/database/tables/budget_snapshots_table.dart` (or add to tables.dart)
- `lib/core/database/tables/pending_recurring_queue_table.dart` (or add to tables.dart)
- `lib/core/database/daos/budget_snapshots_dao.dart`
- `lib/core/database/daos/recurring_queue_dao.dart`
- `lib/features/budget/widgets/recurring_due_banner.dart`
- `lib/features/budget/widgets/recurring_review_sheet.dart`
- `lib/features/budget/widgets/rebalance_sheet.dart`
- `lib/features/analytics/budget_history_screen.dart`
- `lib/features/analytics/budget_history_providers.dart`
- `lib/features/analytics/widgets/budget_history_chart.dart`
- `lib/features/analytics/widgets/budget_history_month_tile.dart`

## Files to Modify

- `lib/core/database/tables.dart` — add new tables + new columns
- `lib/core/database/database.dart` — register new DAOs, bump schema version
- `lib/features/transactions/add_transaction_screen.dart` — add Repeats toggle
- `lib/features/budget/budget_screen.dart` — add banner + Rebalance button
- `lib/features/budget/budget_providers.dart` — wire rollover amounts
- `lib/features/analytics/analytics_screen.dart` — add Budget History tab
- `lib/features/settings/settings_screen.dart` — add global rollover toggle
- `lib/main.dart` — call MonthBoundaryService on startup
