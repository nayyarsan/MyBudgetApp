# User Budgets a Month

## Actor
App user

## Trigger
User opens the Budget screen

## Steps
| Step | Action | Screen/Widget | Provider | DAO | Tables written |
| --- | --- | --- | --- | --- | --- |
| 1 | Open Budget screen | BudgetScreen | budgetProvider | BudgetDao.watchMonthlyBudgets | _ |
| 2 | TBB banner shows available funds | TbbBanner | budgetCalculatorProvider | _ | _ |
| 3 | Tap a category row, enter assigned amount | CategoryRow | budgetProvider | BudgetDao.upsertMonthlyBudget | monthly_budgets |
| 4 | TBB updates in real time | TbbBanner | budgetCalculatorProvider (stream) | _ | _ |
| 5 | Navigate to previous/next month | BudgetScreen | monthBoundaryProvider | _ | _ |

## Happy path end state
A `monthly_budgets` row is created or updated for the category + month key. TBB (To Be Budgeted) value decreases by the assigned amount.

## Edge cases
- Over-assignment makes TBB negative — user is warned via TBB banner colour change
- Month rollover: remaining budget can roll over to next month if category has rollover=true
- Recurring transactions due this month shown via RecurringDueBanner
