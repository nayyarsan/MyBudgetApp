# Architecture

Money in Sight is an offline-first personal finance app built with Flutter. Local SQLite (via Drift) is the source of truth; Firebase is an optional cloud backup.

---

## Directory Structure

```
lib/
├── main.dart                          # Entry point, startup flow
├── core/
│   ├── database/
│   │   ├── database.dart              # Drift AppDatabase singleton + migrations
│   │   ├── tables.dart                # All table definitions
│   │   ├── providers.dart             # databaseProvider (Riverpod)
│   │   └── daos/
│   │       ├── accounts_dao.dart
│   │       ├── categories_dao.dart
│   │       ├── transactions_dao.dart
│   │       ├── budget_dao.dart
│   │       ├── budget_snapshots_dao.dart
│   │       └── recurring_queue_dao.dart
│   ├── services/
│   │   ├── month_boundary_service.dart  # Monthly snapshot/rollover/recurring logic
│   │   ├── month_boundary_provider.dart # Riverpod provider for the service
│   │   └── rollover_provider.dart       # Global rollover setting
│   ├── utils/
│   │   └── currency_formatter.dart      # Cents ↔ dollars
│   ├── theme/
│   │   └── app_theme.dart
│   └── csv/
│       └── csv_parser.dart
└── features/
    ├── shell/          # 5-tab bottom navigation shell
    ├── auth/           # Firebase Auth + biometric lock
    ├── onboarding/     # 6-step setup wizard
    ├── budget/         # Budget screen, rollover, rebalancing, recurring
    ├── transactions/   # Transaction list, add/edit, CSV import
    ├── accounts/       # Account list and detail
    ├── analytics/      # Charts, budget history
    ├── goals/          # Savings goals
    ├── settings/       # Biometric, sync, rollover
    └── sync/           # Firestore sync engine
```

---

## Database (Drift + SQLite)

Schema version: **3**. All migrations live in `database.dart`.

### Tables

| Table | Purpose |
|-------|---------|
| `Accounts` | Bank/credit/cash accounts |
| `CategoryGroups` | Groups of budget categories |
| `Categories` | Individual spending categories with optional goals and rollover flag |
| `MonthlyBudgets` | Assigned + rolledOver cents per category per month |
| `Transactions` | All financial events (expense, income, transfer). Recurring transactions carry `nextDueDate` |
| `BudgetSnapshots` | End-of-month snapshot: assigned vs. spent per category — used for history and rollover |
| `PendingRecurringQueue` | Recurring transactions that are due and awaiting user confirmation |
| `NetWorthSnapshots` | Periodic net worth records |

### Key conventions

**Soft deletes** — Records are never hard-deleted. Every mutable table has `isDeleted: bool` (default false). Queries always filter `WHERE isDeleted = 0`.

**Month keys** — Months are stored as `YYYY-MM` strings (e.g. `"2026-03"`). This avoids timezone ambiguity and keeps range queries simple.

**Cents** — All monetary values are stored as integer cents (`$49.99 → 4999`). Floating-point is never used for money.

---

## State Management (Riverpod)

Providers are co-located with their feature folder. Key providers:

```
databaseProvider            → AppDatabase singleton
selectedMonthProvider       → StateProvider<DateTime> — currently viewed budget month
monthlyBudgetsProvider      → StreamProvider — reactive budgets for selected month
transactionsForMonthProvider → StreamProvider — reactive transactions for selected month
rolloverAmountsProvider     → FutureProvider<Map<categoryId, rolledOverCents>>
rebalanceSuggestionsProvider → FutureProvider<List<RebalanceSuggestion>>
pendingRecurringProvider    → StreamProvider — recurring transactions due for review
globalRolloverEnabledProvider → AsyncNotifierProvider<bool> — persisted to SecureStorage
budgetHistoryProvider       → FutureProvider — monthly snapshots for analytics
firebaseUserProvider        → StreamProvider<User?> — current auth state
biometricEnabledProvider    → FutureProvider<bool>
```

Drift's `.watch()` feeds `StreamProvider`s, so the UI rebuilds automatically whenever the database changes.

---

## App Startup Flow

```
main()
 └─ Firebase.initializeApp()  [try/catch — offline mode if unavailable]
 └─ runApp(ProviderScope → MoneyInSightApp)

MoneyInSightApp
 └─ BiometricLockScreen          [wraps entire app; prompts biometric if enabled]
    └─ _AppStartup
       └─ onboardingCompleteProvider
          ├─ false → OnboardingScreen (6-step wizard)
          └─ true  → addPostFrameCallback:
                        monthBoundaryService.run()  [runs once per month]
                      MainShell (5-tab navigation)
```

---

## MonthBoundaryService

Runs once per calendar month (guarded by `last_snapshot_month` in SecureStorage). Called on first app open after onboarding completes.

```
run(now)
 ├─ _snapshotMonth(previousMonth)
 │   For each category: read budget + sum expenses → upsert BudgetSnapshot
 │
 ├─ _applyRollovers(previousMonth, currentMonth)
 │   For each category where rollover=true:
 │     surplus = max(0, assigned − spent)
 │     upsert MonthlyBudget with rolledOverCents = surplus
 │
 └─ _enqueueRecurring(today)
     For each recurring transaction where nextDueDate ≤ today:
       if not already queued → insert PendingRecurringQueue row
```

Pure static helpers (tested independently):

```dart
computeRolloverCents(assigned, spent) → int   // surplus only, never negative
computeNextDueDate(from, interval)    → DateTime  // weekly / monthly / yearly
```

---

## Budget Calculations

```dart
// Available balance per category
available = (assignedCents + rolledOverCents) - spentCents

// To Be Budgeted (top banner)
toBeBudgeted = totalIncomeCents - totalAssignedCents

// Rebalance suggestion
// Sort overspent categories (worst first), surplus categories (most first)
// Match surpluses to deficits, capped at available surplus
```

---

## Firebase Integration

**Auth** (`firebase_auth_service.dart`)
- Google Sign-In → Firebase credential
- Anonymous fallback if Firebase unavailable
- `firebaseUserProvider` exposes current user as a reactive stream

**Sync** (`sync_service.dart`)
- Unidirectional: local → Firestore only (no pull)
- Writes `users/{uid}/accounts`, `categories`, `categoryGroups`, `transactions`
- Manual trigger from Settings screen
- Last sync timestamp stored in SecureStorage
- Graceful no-op if offline or unauthenticated

---

## Navigation

```
BiometricLockScreen
└─ OnboardingScreen (PageView, 6 steps)  OR
└─ MainShell (IndexedStack, 5 tabs)
   ├─ BudgetScreen
   │   ├─ GoalsScreen (push)
   │   ├─ RebalanceSheet (bottom sheet)
   │   └─ RecurringReviewSheet (bottom sheet)
   ├─ TransactionsScreen
   │   ├─ AddTransactionScreen (push)
   │   └─ ImportCsvScreen (push)
   ├─ AccountsScreen
   │   ├─ AddAccountScreen (push)
   │   └─ AccountDetailScreen (push)
   ├─ AnalyticsScreen (TabBar: Spending | Income vs Expenses | Budget History)
   └─ SettingsScreen
```

Full-screen pushes use `MaterialPageRoute`. Modals use `showDialog` / `showModalBottomSheet`.

---

## Testing

Tests live in `test/`, mirroring the `lib/` structure:

```
test/
├── core/
│   ├── database_test.dart
│   ├── csv_parser_test.dart
│   └── services/
│       └── month_boundary_service_test.dart
└── features/
    ├── budget/
    │   ├── budget_calculator_test.dart
    │   ├── budget_providers_test.dart
    │   └── rebalance_provider_test.dart
    └── transactions/
        └── add_transaction_test.dart
```

Pure logic (calculators, service static methods) is unit tested without database dependencies. Run with:

```bash
flutter test
```
