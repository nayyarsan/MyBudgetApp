# User Imports Transactions from CSV

## Actor
App user

## Trigger
User navigates to Import CSV screen and selects a file

## Steps
| Step | Action | Screen/Widget | Provider | DAO | Tables written |
| --- | --- | --- | --- | --- | --- |
| 1 | Open Import CSV screen | ImportCsvScreen | _ | _ | _ |
| 2 | Select CSV file from device | ImportCsvScreen (file picker) | _ | _ | _ |
| 3 | CSV parsed into transaction objects | ImportCsvScreen | _ | CsvParser.parse | _ |
| 4 | Preview shown, user confirms | ImportCsvScreen | _ | _ | _ |
| 5 | Transactions inserted in batch | ImportCsvScreen | transactionsProvider | TransactionsDao.insertTransaction (×N) | transactions |
| 6 | Transaction list refreshes | TransactionsScreen | transactionsProvider (stream) | _ | _ |

## Happy path end state
N new transaction rows inserted into `transactions`, each with `importedFrom` set to the CSV filename. Account balances updated.

## Edge cases
- Invalid CSV format: parser returns error, no rows inserted
- Duplicate detection: `importedFrom` field identifies source file but no deduplication is enforced by default
- Missing category: rows import without a category (uncategorised)
