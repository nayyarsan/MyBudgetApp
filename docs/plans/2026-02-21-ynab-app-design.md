# Money in Sight — Design Document

**Date:** 2026-02-21
**Status:** Approved
**Platform:** Android (Flutter)
**Currency:** USD only

---

## 1. Overview

A production-ready personal finance Android app inspired by YNAB (You Need A Budget). It implements zero-based budgeting — every dollar is assigned a job — combined with net worth tracking, savings goals, and rich spending analytics. Data lives locally first; Firebase provides optional cloud backup and multi-device restore.

### Core Philosophy (YNAB Principles)
1. **Give every dollar a job** — Unassigned money shows as "To Be Budgeted" until allocated to a category.
2. **Embrace your true expenses** — Large infrequent expenses are budgeted monthly in advance via savings goals.
3. **Roll with the punches** — Overspent categories can be covered by moving money from other categories.
4. **Age your money** — Track how long money sits before being spent; older = more financial stability.

---

## 2. Tech Stack

| Layer | Technology | Reason |
|---|---|---|
| UI Framework | Flutter (Dart) | Beautiful native Android UI, single codebase, can expand to iOS |
| State Management | Riverpod | Testable, scalable, no boilerplate |
| Local Database | Drift (SQLite) | Type-safe, generated queries, migration support |
| Cloud Sync | Firebase Firestore | Offline-first sync, generous free tier (1GB) |
| Authentication | Firebase Auth (Google Sign-In + Anonymous) | No passwords to manage |
| Charts | fl_chart | Best-in-class Flutter charting library |
| CSV Import | csv package + FilePicker | Parse bank statement exports |
| Biometric Auth | local_auth | Fingerprint / face lock |
| DB Encryption | sqflite_sqlcipher | AES-256 encryption at rest |

---

## 3. Architecture

**Pattern: Feature-first Clean Architecture**

```
lib/
├── core/
│   ├── database/        # Drift DB setup, DAOs, migrations
│   ├── firebase/        # Firestore sync service, auth service
│   ├── csv/             # CSV parser, column mapper
│   ├── theme/           # Material 3 theme, colors, typography
│   └── utils/           # Date helpers, currency formatters
├── features/
│   ├── budget/          # Envelope budgeting, category groups, rollover
│   ├── transactions/    # Add, edit, delete, import, search
│   ├── accounts/        # Bank accounts, net worth tracker
│   ├── analytics/       # Charts, trends, spending insights
│   ├── goals/           # Savings goals with progress tracking
│   └── auth/            # Sign-in, biometric lock, session
└── main.dart
```

**Data flow:**
```
UI (Flutter Widgets)
    ↕ Riverpod Providers
Feature Logic (use cases, calculators)
    ↕
Drift DAOs (SQLite — source of truth)
    ↓ background sync
Firebase Firestore (cloud backup)
```

All reads come from SQLite. Firebase is write-behind only — the app works fully offline.

---

## 4. Data Model

```sql
-- Bank/cash accounts
Account:
  id, name, type (checking|savings|credit|cash),
  balance, institution, createdAt, updatedAt

-- Budget category groups and categories
CategoryGroup:
  id, name, sortOrder

Category:
  id, groupId, name, rollover (bool),
  goalAmount, goalDate, goalType (targetBalance|monthlyContribution),
  createdAt

-- Monthly budget allocation per category
MonthlyBudget:
  id, categoryId, month (YYYY-MM),
  assigned, activity (computed), available (computed)

-- Every dollar in or out
Transaction:
  id, accountId, categoryId, amount (cents, signed),
  payee, date, memo, type (income|expense|transfer),
  cleared (bool), recurring (bool), recurringInterval,
  importedFrom, createdAt, updatedAt

-- Net worth snapshots (recorded monthly)
NetWorthSnapshot:
  id, date, totalAssets, totalLiabilities, netWorth

-- Sync metadata
SyncLog:
  id, entityType, entityId, operation, syncedAt, firestoreDocId
```

> Amounts stored as integer cents to avoid floating-point rounding errors.

---

## 5. Features

### 5.1 Zero-Based Budgeting
- Monthly view with "To Be Budgeted" (TBB) banner at top
- TBB = total income this month − total assigned to categories
- Categories show three columns: **Budgeted | Spent | Available**
- Available = budgeted + rolled-over − spent
- Overspent categories highlighted in red; money can be moved from other categories
- Month navigation (prev/next) with copy-last-month budget option

### 5.2 Envelope Categories
- Categories organized into groups (e.g., Housing, Food, Transport)
- Per-category rollover toggle
- Drag-and-drop reorder
- Quick-assign: tap Available amount to move money

### 5.3 Transactions
- Manual entry: account, category, amount, payee, date, memo, recurring toggle
- Split transactions: one transaction split across multiple categories
- Recurring transactions: daily/weekly/monthly auto-generation
- Swipe to edit/delete
- Search by payee, memo, amount
- Filter by account, category, date range, cleared status
- Mark as cleared (reconciliation workflow)

### 5.4 CSV Import
1. FilePicker → select bank CSV/Excel export
2. Auto-detect columns; user maps: Date / Amount / Payee / Memo
3. Preview first 10 rows with validation errors flagged
4. Confirm → bulk insert → sync to Firestore
5. Duplicate detection by (date + amount + payee)

### 5.5 Accounts & Net Worth
- Add checking, savings, credit card, cash accounts
- Account reconciliation workflow (mark transactions cleared, adjust balance)
- Net worth card: total assets − total liabilities
- Net worth tracked monthly as snapshots

### 5.6 Savings Goals
- Per-category goal: target amount + target date
- Two goal types: Target Balance (save up to X) and Monthly Contribution (save X/month)
- Progress bar on category card
- Projected completion date based on current pace

### 5.7 Age of Money
- Calculated as: average days between income receipt and expense spending
- Displayed as a single metric on the Analytics screen
- Color-coded: < 10 days (red), 10–30 (yellow), > 30 (green)

---

## 6. UI / Navigation

**Bottom navigation bar — 5 tabs:**

| Tab | Icon | Primary Purpose |
|---|---|---|
| Budget | wallet | Monthly envelope view — main screen |
| Transactions | list | Full log, search, filter, import |
| Accounts | bank | Account balances, net worth |
| Analytics | chart | Charts, trends, insights |
| Settings | gear | Profile, sync, theme, export |

**Design language:**
- Material 3 (Material You)
- Primary color: Deep teal (`#1B6CA8` / `#2DC9A4` accent)
- Dark mode + light mode (follows system, toggleable in settings)
- Rounded cards, generous whitespace, clear typography hierarchy

**Key screens:**

| Screen | Description |
|---|---|
| Budget Home | Month selector, TBB banner, category group accordion |
| Category Detail | Spending history, goal progress, budget adjustment slider |
| Add Transaction | Full form with smart payee autocomplete |
| Transaction List | Searchable, filterable, swipe actions |
| CSV Import | File picker → column mapper → preview → confirm |
| Accounts | Account cards with balances, net worth summary card |
| Analytics | Tabbed: Overview, Spending, Income, Net Worth, Goals |
| Settings | Account, sync status, biometric toggle, data export, theme |

---

## 7. Analytics

All charts powered by `fl_chart`:

| Chart | Type | Timeframe |
|---|---|---|
| Spending by Category | Donut chart | Current month; tap to drill down |
| Spending Over Time | Line chart | Last 6 months, per category or total |
| Income vs Expenses | Grouped bar chart | Monthly, last 12 months |
| Net Worth Trend | Area chart | Rolling 12 months |
| Savings Rate | Radial gauge | Current month % |
| Age of Money | Metric card | Rolling 30-day average |
| Recurring Expenses | Sorted list | Auto-detected repeating payees + amounts |

---

## 8. Cloud Sync Strategy

**Offline-first:**
```
Write → SQLite immediately (user sees result instantly)
      → queue sync job
      → Firestore write in background (when online)

Read → always from SQLite (never waits for network)

New device restore:
  Sign in → fetch Firestore → populate SQLite → ready
```

**Firestore structure:**
```
users/{uid}/
  accounts/{accountId}
  categories/{categoryId}
  categoryGroups/{groupId}
  transactions/{transactionId}
  monthlyBudgets/{budgetId}
  netWorthSnapshots/{snapshotId}
  goals/{goalId}
```

**Conflict resolution:** Last-write-wins using `updatedAt` timestamp. Soft deletes (`deletedAt`) to propagate deletions across devices.

**Sync triggers:** App foreground, transaction save, every 15 minutes via background isolate.

---

## 9. Security

### Authentication
- Google Sign-In via Firebase Auth (recommended)
- Anonymous auth (data stays local until user signs in)
- Auto-token refresh, secure token storage via Flutter Secure Storage

### Data at Rest
- SQLite database encrypted with AES-256 (`sqflite_sqlcipher`)
- Encryption key stored in Android Keystore (hardware-backed, non-extractable)

### Data in Transit
- All Firebase communication over TLS 1.3
- No custom backend — Firebase SDK handles all networking

### Data in Cloud
- Firestore Security Rules: users read/write only `users/{uid}/` — enforced server-side
- No admin read access to user data

### App-Level
- Biometric lock (fingerprint/face) on app open via `local_auth`
- Auto-lock after configurable timeout (default: 5 minutes in background)
- Screenshot prevention (`FLAG_SECURE`) on all screens
- No sensitive data in logs or crash reports (Firebase Crashlytics with PII scrubbing)

### CSV Import Safety
- Files parsed in memory only, never persisted as raw files
- Pure data parsing — no code execution from imported content

---

## 10. Error Handling

- All DB operations: try/catch with user-friendly SnackBar error messages
- Firebase failures: silent retry with exponential backoff — local app always works
- CSV import: per-row validation, bad rows flagged with row number; user can skip or abort
- Form validation: all required fields validated before save with inline error text
- Network errors: shown as subtle sync status indicator (not blocking UI)

---

## 11. Testing Strategy

| Layer | Tool | What |
|---|---|---|
| Unit | `flutter_test` | Budget calculations, rollover logic, CSV parser, sync conflict resolution, age-of-money formula |
| Widget | `flutter_test` | Transaction form, budget screen category cards, analytics charts render |
| Integration | `integration_test` | Full flow: add account → assign budget → add transaction → verify analytics update |
| Firebase | Firebase Emulator Suite | Cloud sync, auth, Firestore rules |

---

## 12. Production Readiness Checklist

- [ ] Crashlytics error reporting (PII-scrubbed)
- [ ] Firebase Performance Monitoring
- [ ] App signing with release keystore
- [ ] ProGuard/R8 code shrinking enabled
- [ ] Minimum Android SDK: API 26 (Android 8.0) — covers 95%+ of active devices
- [ ] Target SDK: latest stable
- [ ] Play Store listing: screenshots, privacy policy, data safety form
- [ ] Privacy policy covering Firebase data usage
- [ ] Automated backup disabled for SQLite (encrypted — Android backup would be useless anyway)
- [ ] Deep link support for future web companion

---

*Design approved 2026-02-21. Proceed to implementation planning.*
