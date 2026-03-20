# User Sets a Financial Goal

## Actor
App user

## Trigger
User taps 'Add Goal' on the Goals screen or edits a category's goal

## Steps
| Step | Action | Screen/Widget | Provider | DAO | Tables written |
| --- | --- | --- | --- | --- | --- |
| 1 | Open Goals screen | GoalsScreen | goalsProvider | CategoriesDao.watchAllCategories | _ |
| 2 | Tap 'Add Goal' | GoalsScreen | _ | _ | _ |
| 3 | Select category, enter target amount and date | AddGoalScreen | _ | _ | _ |
| 4 | Tap 'Save' | AddGoalScreen | goalsProvider | CategoriesDao.updateCategory | categories |
| 5 | Goal progress calculated | GoalsScreen | goalCalculatorProvider | _ | _ |
| 6 | Goals list refreshes | GoalsScreen | goalsProvider (stream) | _ | _ |

## Happy path end state
The `categories` row for the selected category is updated with `goalAmountCents`, `goalDate`, and `goalType`. Goal progress is computed and displayed.

## Edge cases
- Goal date must be in the future
- Target amount must be > 0
- If no monthly budget is assigned, goal completion will take longer than projected
