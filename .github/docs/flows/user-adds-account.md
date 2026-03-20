# User Adds an Account

## Actor
App user

## Trigger
User taps 'Add Account' button on the Accounts screen

## Steps
| Step | Action | Screen/Widget | Provider | DAO | Tables written |
| --- | --- | --- | --- | --- | --- |
| 1 | Tap 'Add Account' | AccountsScreen | accountsProvider | _ | _ |
| 2 | Enter name, type, opening balance | AddAccountScreen | _ | _ | _ |
| 3 | Tap 'Save' | AddAccountScreen | accountsProvider | AccountsDao.insertAccount | accounts |
| 4 | Account list refreshes via stream | AccountsScreen | accountsProvider (stream) | AccountsDao.watchAllAccounts | _ |

## Happy path end state
A new row is inserted into the `accounts` table. The account list screen shows the new account immediately via the reactive stream.

## Edge cases
- Name must be at least 1 character (Drift validation)
- Opening balance defaults to 0 if left blank
- Offline: account is saved locally only; sync to Firestore on next manual sync
