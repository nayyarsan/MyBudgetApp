# Account Management

## What it does
Allows users to create and manage their financial accounts (checking, savings, credit cards, cash). Users can add accounts with opening balances, view account details and transaction history, and soft-delete accounts they no longer need.

## User actions
- Add a new account with name, type, and opening balance
- View account details and running balance
- View transactions for a specific account
- Edit or delete an account

## Screens and widgets
- `lib/features/accounts/account_detail_screen.dart`
- `lib/features/accounts/accounts_screen.dart`
- `lib/features/accounts/add_account_screen.dart`

## Providers
- `lib/features/accounts/account_providers.dart`

## Services
_none_

## Provider chain
Data flows from screen → provider (`accounts_providers.dart`) → DAO → Drift table.
Providers are watched reactively; stream-returning DAO methods push updates automatically.

## Data model
| Table | Operations | Reactive? |
| --- | --- | --- |
| accounts | read+write | yes |
| transactions | read | yes |

## Dependencies on other features
_none_

## Known gaps
_none identified_
