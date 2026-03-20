# Navigation Shell

## What it does
The main navigation scaffold housing the bottom navigation bar. Routes between Accounts, Budget, Transactions, Analytics, and Goals features.

## User actions
- Switch between main app sections via bottom navigation

## Screens and widgets
- `lib/features/shell/main_shell.dart`

## Providers
_none_

## Services
_none_

## Provider chain
Data flows from screen → provider (`shell_providers.dart`) → DAO → Drift table.
Providers are watched reactively; stream-returning DAO methods push updates automatically.

## Data model
_no direct table access_

## Dependencies on other features
`accounts`, `budget`, `transactions`, `analytics`, `goals`

## Known gaps
_none identified_
