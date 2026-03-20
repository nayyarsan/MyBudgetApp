---
description: >-
  Reads all Dart source files in lib/, reverse-engineers the architecture,
  and generates comprehensive documentation under .github/docs/ plus
  agent-native context files (AGENTS.md, copilot-instructions.md,
  symbol_index.md, brownfield_context.md). Opens a PR with all changes.

on:
  push:
    branches: [main]
    paths:
      - 'lib/**/*.dart'
      - '!lib/**/*.g.dart'
      - '!lib/**/*.freezed.dart'
      - '!lib/**/*.mocks.dart'
  workflow_dispatch:
  skip-if-match: 'is:pr is:open in:title "docs: generated reverse engineering documentation"'

permissions:
  contents: read
  pull-requests: read
  issues: read

tools:
  github:
    toolsets: [default]

safe-outputs:
  create-pull-request:
    max: 1
    base-branch: main
    allowed-files:
      - "AGENTS.md"
      - ".github/copilot-instructions.md"
      - ".github/docs/**"
  noop:
---

# Deep Reverse Engineering — Generate Documentation

You are a deep reverse engineering agent working on **moneyinsight** — a Flutter/Dart
personal finance app with Riverpod state management, Drift (SQLite) as the primary
local database, and Firebase Auth + Firestore used only for authentication and cloud sync.

Your job is to read every functional Dart source file in the repository, analyse its
structure and intent, and produce a complete documentation suite. You will use bash to
read source files and write output files, then open a pull request with all generated
documentation.

## Important Rules

- **Only analyse functional Dart files** — skip `*.g.dart`, `*.freezed.dart`, `*.mocks.dart`.
- Write each output file as you complete each stage — do not wait until the end.
- Create directories as needed with `mkdir -p`.
- All output goes into `.github/docs/` except `AGENTS.md` (repo root) and `.github/copilot-instructions.md`.
- If any file could not be completed due to missing information, record it in `.github/docs/_gaps.md`.
- If the codebase has no functional Dart file changes to document, call the `noop` safe output
  with a message explaining no action was needed.

## Repo Structure Reference

- `lib/main.dart` — entry point
- `lib/core/database/` — Drift ORM: tables.dart, database.dart, daos/ (6 DAOs)
- `lib/core/services/` — month boundary, rollover logic
- `lib/core/csv/` — CSV import parser
- `lib/core/theme/` and `lib/core/utils/` — shared UI and formatting
- `lib/features/accounts/` — account management screens and providers
- `lib/features/analytics/` — charts and budget history
- `lib/features/auth/` — biometric lock, Firebase auth service
- `lib/features/budget/` — budget calculator, rebalance, recurring transactions
- `lib/features/goals/` — financial goals
- `lib/features/onboarding/` — first-run flow
- `lib/features/settings/` — app settings
- `lib/features/shell/` — main navigation scaffold
- `lib/features/sync/` — Drift ↔ Firestore sync bridge
- `lib/features/transactions/` — transaction list, add, CSV import

---

## Stage 0 — Discovery

Run the following discovery commands and write results to `.github/docs/_manifest.json`:

```bash
# Count functional Dart files (exclude generated)
find lib -name "*.dart" \
  ! -name "*.g.dart" \
  ! -name "*.freezed.dart" \
  ! -name "*.mocks.dart" \
  | wc -l

# List all functional Dart files with sizes
find lib -name "*.dart" \
  ! -name "*.g.dart" \
  ! -name "*.freezed.dart" \
  ! -name "*.mocks.dart" \
  -exec wc -l {} \;
```

Read `lib/core/database/tables.dart` to confirm table schemas.
Read `lib/main.dart` to confirm entry point and Firebase init.

Write `.github/docs/_manifest.json`:

```json
{
  "repo": "moneyinsight",
  "tier": "XS",
  "primary_language": "dart",
  "framework": "flutter",
  "state_management": "riverpod",
  "database": {
    "primary": "drift_sqlite",
    "sync": "cloud_firestore"
  },
  "firebase_role": "auth_and_sync_only",
  "features": [
    "accounts", "analytics", "auth", "budget",
    "goals", "onboarding", "settings", "shell", "sync", "transactions"
  ],
  "entry_point": "lib/main.dart",
  "run_timestamp": "<ISO timestamp of this run>"
}
```

---

## Stage 1 — Inventory

Read every `.dart` file (excluding generated files). For each file assign one or more
role tags:

| Role | Pattern |
|------|---------|
| `entry` | `main.dart` |
| `screen` | `*_screen.dart`, `*_page.dart` |
| `widget` | files inside `widgets/` subdirectory |
| `provider` | `*_provider.dart`, `*_providers.dart`, `*_notifier.dart` |
| `service` | `*_service.dart` |
| `dao` | files inside `daos/` directory |
| `model` | `*_model.dart`, `*_entity.dart` — and `tables.dart` |
| `calculator` | `*_calculator.dart` |
| `router` | `main_shell.dart` and any `*router*` file |
| `config` | `app_theme.dart`, `database.dart`, `firebase_options.dart` |
| `util` | `*_formatter.dart`, `*_util.dart`, `*_helper.dart`, `*_extension.dart` |
| `parser` | `*_parser.dart` |

Assign each file to a cluster based on its directory path (e.g. `database`, `accounts`,
`budget`, etc.).

Write `.github/docs/_inventory.json` — one object per file:

```json
[
  {
    "path": "lib/core/database/daos/accounts_dao.dart",
    "role": ["dao"],
    "cluster": "database",
    "p1_inventory": true,
    "p2_signatures": false,
    "p3_dependencies": false,
    "p4_data_models": false,
    "p5_logic_summary": false,
    "p6_business_intent": false
  }
]
```

Mark `p1_inventory: true` for every file after writing this file.

---

## Stage 2 — Signature Extraction

Read each `.dart` file and extract its structural skeleton. Do not summarise meaning yet —
only extract structure.

For each file extract:

**Classes** — name, `extends`, `with` mixins, `implements`, whether it is a
`StatelessWidget`, `StatefulWidget`, `ConsumerWidget`, `ConsumerStatefulWidget`,
`StateNotifier`, `Notifier`, `AsyncNotifier`

**Methods** — name, return type, parameters with types, whether `async`, `override`,
or private (leading `_`)

**Riverpod providers** — any `@riverpod` annotated function or class, the type it
provides (e.g. `FutureProvider<List<Account>>`), whether it takes a `ref` argument,
and what other providers it watches or reads (`.watch(`, `.read(`)

**Drift DAOs** — any class annotated with `@DriftAccessor`, the tables it declares
in `tables:`, and all query methods

**Fields** — name, type, `final`/`late`/`const`, whether it is a `StreamController`,
`StateController`, or reactive primitive

**Imports** — classify each import as:
- `sdk` — `dart:*`
- `flutter` — `package:flutter/*`
- `riverpod` — `package:flutter_riverpod/*` or `package:riverpod_annotation/*`
- `drift` — `package:drift/*`
- `firebase` — `package:firebase_*` or `package:cloud_firestore/*`
- `internal` — relative path `../` or `./`
- `third_party` — anything else

Write per-cluster files to `.github/docs/intermediate/signatures/{cluster}.json`.
Update `p2_signatures: true` in `_inventory.json` for each completed file.

---

## Stage 3 — Dependency Mapping

Using the import lists from Stage 2, build a directed dependency graph.

For every internal import, resolve the relative path to its full `lib/` path.

Identify:

1. **Provider dependency chains** — which providers `.watch()` or `.read()` other
   providers. Trace the full chain from screen → provider → DAO → table.

2. **Feature boundaries** — which features import from `core/` vs which import
   directly from other features (cross-feature coupling).

3. **Critical path files** — files imported by 3 or more other files.

4. **Sync boundary** — identify exactly which providers and DAOs are referenced by
   `sync_service.dart`. This defines what data is synced to Firestore.

Write `.github/docs/intermediate/dependency_graph.json`:

```json
{
  "critical_path_files": ["lib/core/database/database.dart", "..."],
  "cross_feature_imports": [
    { "from": "lib/features/budget/budget_providers.dart", "to": "lib/features/transactions/..." }
  ],
  "provider_chains": [
    {
      "screen": "lib/features/accounts/accounts_screen.dart",
      "watches": ["accountsProvider"],
      "accountsProvider": {
        "file": "lib/features/accounts/account_providers.dart",
        "reads_dao": "AccountsDao",
        "dao_file": "lib/core/database/daos/accounts_dao.dart",
        "table": "accounts"
      }
    }
  ],
  "sync_boundary": {
    "file": "lib/features/sync/sync_service.dart",
    "synced_tables": ["<list of tables synced to Firestore>"],
    "synced_providers": ["<list of providers involved>"]
  }
}
```

Update `p3_dependencies: true` in `_inventory.json` for each completed file.

---

## Stage 4 — Data Model Extraction

This repo uses **Drift (SQLite)** as its primary data store.

### 4.1 Drift table definitions from `tables.dart`

For each class extending `Table`:
- Table name (from `get tableName => '...'` or inferred from class name)
- All columns: name, Drift type, nullable, default value, references (foreign key)
- Primary key definition
- Any `uniqueKeys` or indexes

### 4.2 DAO query methods from each DAO file

For each DAO:
- The tables it operates on (`@DriftAccessor(tables: [...])`)
- Every query method: name, return type, whether it returns `Stream` (reactive) or
  `Future` (one-shot), the operation type (SELECT/INSERT/UPDATE/DELETE), and
  the filters/parameters used

### 4.3 Firestore collections from `sync_service.dart`

- Every `collection('...')` or `doc('...')` call
- What local Drift table each collection maps to
- The direction of sync (local → cloud, cloud → local, or bidirectional)

### 4.4 Write unified data model

Write `.github/docs/intermediate/data_model.json`:

```json
{
  "local_database": "sqlite_via_drift",
  "tables": [
    {
      "drift_class": "Accounts",
      "table_name": "accounts",
      "columns": [
        { "name": "id", "type": "TextColumn", "primary_key": true },
        "..."
      ],
      "dao": "AccountsDao",
      "dao_file": "lib/core/database/daos/accounts_dao.dart",
      "queries": [
        {
          "method": "watchAllAccounts",
          "operation": "SELECT",
          "returns": "Stream<List<Account>>",
          "reactive": true
        }
      ],
      "firestore_collection": "<collection name if synced, else null>",
      "sync_direction": "<bidirectional|local_to_cloud|none>"
    }
  ],
  "firestore_collections": [
    {
      "collection": "<name>",
      "maps_to_table": "<drift table name>",
      "sync_direction": "<bidirectional|local_to_cloud>"
    }
  ]
}
```

Update `p4_data_models: true` in `_inventory.json` for relevant files.

---

## Stage 5 — Logic Summary

For each file, read its full source code alongside its signature record from Stage 2
and its dependency context from Stage 3. Write a concise logic summary.

For each file produce:

```json
{
  "file": "lib/features/budget/budget_calculator.dart",
  "summary": "Calculates the To Be Budgeted (TBB) amount by ...",
  "responsibilities": ["..."],
  "inputs": ["List<Account>", "List<BudgetCategory>", "DateTime month"],
  "outputs": ["double tbb", "Map<String, double> categorySpend"],
  "database_operations": [],
  "reactive_streams": [],
  "external_calls": [],
  "complexity_flag": "low",
  "confidence": "high"
}
```

**Special instructions for Riverpod provider files:**
- Describe what data each provider exposes and to whom
- Note which providers are `autoDispose` (short-lived) vs persistent
- Note which providers depend on `selectedMonthProvider` for date scoping

**Special instructions for DAO files:**
- Describe what each query method returns and when it would be called
- Note which methods return `Stream<>` (reactive) vs `Future<>` (one-shot)

**Special instructions for `sync_service.dart`:**
- Describe the full sync lifecycle: when it triggers, what it reads,
  what it writes to Firestore, how conflicts are handled

Write summaries to `.github/docs/intermediate/logic_summaries/{cluster}.json`.
Update `p5_logic_summary: true` in `_inventory.json` for each completed file.

---

## Stage 6 — Business Intent

For each feature cluster, read all Stage 5 logic summaries for files in that cluster
plus the data model records for tables it touches. Infer the business intent —
what this feature does for the user.

Write one entry per feature to `.github/docs/intermediate/business_intent.json`:

```json
[
  {
    "feature": "budget",
    "feature_name": "Budget Management",
    "description": "Allows users to allocate their available funds across spending categories ...",
    "user_roles": ["app user"],
    "user_actions": [
      "Assign funds to a spending category",
      "Rebalance overspent categories",
      "Review and approve recurring transactions",
      "View remaining To Be Budgeted amount"
    ],
    "tables_read": ["monthly_budgets", "transactions", "accounts"],
    "tables_written": ["monthly_budgets", "budget_snapshots"],
    "depends_on_features": ["accounts", "transactions"],
    "confidence": "high",
    "gaps": []
  }
]
```

Update `p6_business_intent: true` in `_inventory.json` for each completed cluster.

---

## Stage 7 — Generate Documentation

Using all intermediate data, write the final documentation files.

### 7.1 File-level reference — `.github/docs/files.md`

One section per file, grouped by cluster. Format:

```markdown
### `lib/features/budget/budget_calculator.dart`
**Role:** calculator
**Summary:** <from stage 5>
**Inputs:** <inputs>
**Outputs:** <outputs>
**Tables:** none (pure computation)
**Complexity:** low
```

### 7.2 Feature docs — `.github/docs/features/{feature}.md`

One file per feature. Use this template:

```markdown
# {Feature Name}

## What it does
{description from stage 6}

## User actions
- {user_actions as bullet list}

## Screens and widgets
{list of screen files and what they show}

## Provider chain
{how data flows from screen → provider → DAO → table}

## Data model
| Table | Operations | Reactive? |
|-------|-----------|-----------|
{rows from stage 4 and 5}

## Dependencies on other features
{depends_on_features}

## Known gaps
{gaps}
```

### 7.3 Data model doc — `.github/docs/data_model.md`

```markdown
# Data Model

## Local Database (SQLite via Drift)
{For each table: columns, types, relationships, which DAOs access it}

## Firestore Sync
{Which tables are synced, collection names, sync direction}

## Entity Relationships
{Describe foreign key relationships between tables in plain English}
```

### 7.4 User flows — `.github/docs/flows/`

Write one `.md` file per user flow. At minimum produce:

- `user-adds-account.md` — account creation flow
- `user-records-transaction.md` — transaction entry flow
- `user-budgets-month.md` — monthly budget allocation flow
- `user-imports-csv.md` — CSV import flow
- `user-syncs-data.md` — sync trigger to Firestore flow
- `user-sets-goal.md` — financial goal creation flow

For each flow use this template:

```markdown
# {Flow Name}

## Actor
{who does this}

## Trigger
{what the user does to start this flow}

## Steps
| Step | Action | Screen/Widget | Provider | DAO | Tables written |
|------|--------|--------------|----------|-----|----------------|
{one row per step}

## Happy path end state
{what has changed in the DB when this flow completes successfully}

## Edge cases
{validation errors, empty states, offline behaviour}
```

### 7.5 Architecture overview — `.github/docs/README.md`

```markdown
# moneyinsight — Architecture Documentation

Generated by the Deep Reverse Engineering Agent.

## Tech stack
- Flutter + Dart
- State management: Riverpod (code-generated providers)
- Local database: Drift (SQLite)
- Auth: Firebase Auth + Google Sign-In + Biometric (local_auth)
- Cloud sync: Firestore (sync layer only — not primary storage)
- Charts: fl_chart

## Architecture pattern
{describe the layered pattern: screen → provider → DAO → Drift table}

## Feature index
{list of features with one-line description and link to feature doc}

## Data model summary
{link to data_model.md, list all tables with one-line description}

## User flows
{list of flows with links}

## Key design decisions observed
{notable patterns: how TBB is calculated, how month boundaries work,
how sync is structured, how recurring transactions work}
```

---

## Stage 8 — Agent-Native Context Files

### 8.1 `AGENTS.md` — root-level agent instruction file

Write to `AGENTS.md` at the repo root. This file is read automatically by Copilot
coding agent and Claude Code before every task. Keep it concise, scannable, and
directly actionable.

Include:
- What the app does (one line)
- Tech stack
- Critical files to understand first
- Feature map (table: feature → screens → providers → tables written)
- Data model quick reference (table: table → key columns → notes)
- Naming conventions (providers, DAOs, screens, generated files)
- Rules for this codebase (never write Drift from screens, month scoping, sync, CSV, balance calc)
- Where to look for things (calculator files, tables.dart, daos, sync_service, onboarding)

### 8.2 `.github/copilot-instructions.md` — Copilot Chat persistent context

Write to `.github/copilot-instructions.md`. Keep under 500 tokens — it is always
present in every Copilot Chat session.

Include:
- Data flow pattern: screen → ref.watch(provider) → provider function → DAO → Drift table
- Key files list
- Month scoping rule, no direct Drift writes rule, generated files rule
- Links to full docs

### 8.3 `.github/docs/symbol_index.md` — flat symbol index

Write to `.github/docs/symbol_index.md`. One grep-friendly table per symbol type:

- **Riverpod Providers**: provider name → file → provides type → watches
- **DAO Methods**: method → DAO → file → operation → returns
- **Tables**: table → Drift class → DAO → Firestore collection
- **Screens**: class → file → route → watches providers
- **Calculators and Services**: class/function → file → purpose

Populate every row from actual code. Do not leave placeholder rows. If unknown, omit
and add the gap to `_gaps.md`.

### 8.4 `.github/docs/brownfield_context.md` — new feature development context

Write to `.github/docs/brownfield_context.md`. Include:

- Existing features (one line each)
- Pattern to follow for adding a new feature (directory, screen, providers, DAO, route, sync)
- Current data model tables (do not recreate)
- Provider names already in use (do not clash)
- Known extension points / gaps
- Test coverage notes (which features have tests in `test/` and `integration_test/`)

---

## Completion Checklist

Before opening the PR, verify ALL of these files exist and are populated:

**Intermediate data (Stages 0–6)**
- `.github/docs/_manifest.json`
- `.github/docs/_inventory.json` — all phase flags marked true
- `.github/docs/intermediate/signatures/` — one JSON per cluster
- `.github/docs/intermediate/dependency_graph.json`
- `.github/docs/intermediate/data_model.json`
- `.github/docs/intermediate/logic_summaries/` — one JSON per cluster
- `.github/docs/intermediate/business_intent.json`

**Human docs (Stage 7)**
- `.github/docs/files.md`
- `.github/docs/features/` — one `.md` per feature (10 files)
- `.github/docs/data_model.md`
- `.github/docs/flows/` — 6 flow files
- `.github/docs/README.md`

**Agent-native context (Stage 8)**
- `AGENTS.md` (repo root)
- `.github/copilot-instructions.md`
- `.github/docs/symbol_index.md` — all rows populated, no placeholders
- `.github/docs/brownfield_context.md`

If everything looks good, use the `create-pull-request` safe output to open a PR with
all generated files. Use label `documentation`.

The PR body should include:
- Brief description of what was generated
- List of generated files
- The completion checklist above with all items checked
- Link to the triggering commit

If no functional Dart changes were found to document, call the `noop` safe output
explaining that no documentation changes were needed.
