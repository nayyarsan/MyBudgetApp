# Transaction Management

## What it does
Core feature for recording and reviewing financial transactions. Users can add income, expense, and transfer transactions, categorise them, mark them as cleared, and import bulk transactions from CSV files. Transaction list is filterable by account and month.

## User actions
- Add a new income, expense, or transfer transaction
- Assign a category to a transaction
- Mark a transaction as cleared
- Import transactions from a CSV file
- View transaction list filtered by account or month
- Edit or delete an existing transaction

## Screens and widgets
- `lib/features/transactions/add_transaction_screen.dart`
- `lib/features/transactions/import_csv_screen.dart`
- `lib/features/transactions/transactions_screen.dart`

## Providers
_none_

## Services
_none_

## Provider chain
Data flows from screen → provider (`transactions_providers.dart`) → DAO → Drift table.
Providers are watched reactively; stream-returning DAO methods push updates automatically.

## Data model
| Table | Operations | Reactive? |
| --- | --- | --- |
| transactions | read+write | yes |
| accounts | read+write | yes |
| categories | read | yes |

## Dependencies on other features
`accounts`

## Known gaps
_none identified_
