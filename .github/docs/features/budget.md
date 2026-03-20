# Budget Management

## What it does
Allows users to allocate available funds across spending categories for a given month using an envelope-budgeting (YNAB-style) approach. Users assign amounts to categories, see their To Be Budgeted balance update in real time, rebalance overspent categories, and review recurring transactions due this month.

## User actions
- Assign funds to a spending category
- Rebalance overspent categories
- Review and approve recurring transactions
- View remaining To Be Budgeted amount
- Navigate between months

## Screens and widgets
- `lib/features/budget/budget_screen.dart`

## Providers
- `lib/features/budget/budget_providers.dart`
- `lib/features/budget/rebalance_provider.dart`
- `lib/features/budget/recurring_providers.dart`

## Services
_none_

## Provider chain
Data flows from screen → provider (`budget_providers.dart`) → DAO → Drift table.
Providers are watched reactively; stream-returning DAO methods push updates automatically.

## Data model
| Table | Operations | Reactive? |
| --- | --- | --- |
| monthly_budgets | read+write | yes |
| categories | read | yes |
| transactions | read | yes |
| accounts | read | yes |
| budget_snapshots | read+write | no |

## Dependencies on other features
`accounts`, `transactions`

## Known gaps
_none identified_
