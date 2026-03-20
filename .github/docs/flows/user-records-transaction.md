# User Records a Transaction

## Actor
App user

## Trigger
User taps 'Add Transaction' button on the Transactions screen

## Steps
| Step | Action | Screen/Widget | Provider | DAO | Tables written |
| --- | --- | --- | --- | --- | --- |
| 1 | Tap 'Add Transaction' | TransactionsScreen | _ | _ | _ |
| 2 | Select account, type (income/expense/transfer), amount, payee, category | AddTransactionScreen | _ | _ | _ |
| 3 | Tap 'Save' | AddTransactionScreen | transactionsProvider | TransactionsDao.insertTransaction | transactions |
| 4 | Account balance updated | _ | accountsProvider | AccountsDao.updateAccount | accounts |
| 5 | Transaction list refreshes | TransactionsScreen | transactionsProvider (stream) | TransactionsDao.watchTransactions | _ |

## Happy path end state
New transaction row in `transactions`. Account `balanceCents` updated. Reactive streams update all watchers.

## Edge cases
- Transfer type requires selecting a destination account
- Category is optional for income/expense (uncategorised transactions are allowed)
- Recurring flag schedules a future entry in pending_recurring_queue
