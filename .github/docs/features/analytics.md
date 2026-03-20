# Analytics & Budget History

## What it does
Provides charts and historical views of spending by category and income vs expenses over time. Also shows monthly budget snapshots so users can track their budgeting performance across months.

## User actions
- View spending breakdown by category (pie/bar chart)
- View income vs expense chart
- Browse historical monthly budget snapshots

## Screens and widgets
- `lib/features/analytics/analytics_screen.dart`
- `lib/features/analytics/budget_history_screen.dart`

## Providers
- `lib/features/analytics/analytics_providers.dart`
- `lib/features/analytics/budget_history_providers.dart`

## Services
_none_

## Provider chain
Data flows from screen → provider (`analytics_providers.dart`) → DAO → Drift table.
Providers are watched reactively; stream-returning DAO methods push updates automatically.

## Data model
| Table | Operations | Reactive? |
| --- | --- | --- |
| transactions | read | yes |
| categories | read | yes |
| budget_snapshots | read | yes |
| monthly_budgets | read | yes |

## Dependencies on other features
`budget`, `transactions`

## Known gaps
_none identified_
