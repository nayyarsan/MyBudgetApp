# Financial Goals

## What it does
Lets users set savings goals on categories (target amount + target date). A calculator computes progress and estimated monthly contribution required to reach each goal.

## User actions
- Create a savings goal on a category
- View goal progress and projected completion date
- Edit or remove a goal

## Screens and widgets
- `lib/features/goals/add_goal_screen.dart`
- `lib/features/goals/goals_screen.dart`

## Providers
- `lib/features/goals/goals_providers.dart`

## Services
_none_

## Provider chain
Data flows from screen → provider (`goals_providers.dart`) → DAO → Drift table.
Providers are watched reactively; stream-returning DAO methods push updates automatically.

## Data model
| Table | Operations | Reactive? |
| --- | --- | --- |
| categories | read+write | yes |
| monthly_budgets | read | yes |

## Dependencies on other features
`budget`

## Known gaps
_none identified_
