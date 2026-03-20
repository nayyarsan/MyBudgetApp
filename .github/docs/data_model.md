# Data Model

## Local Database (SQLite via Drift)

### `accounts` (`Accounts`)
**DAO:** `AccountsDao` — `lib/core/database/daos/accounts_dao.dart`
| Column | Type | PK | Nullable | References |
| --- | --- | --- | --- | --- |
| id | integer | ✓ |  |  |
| name | text |  |  |  |
| type | text |  |  |  |
| balanceCents | integer |  |  |  |
| institution | text |  | ✓ |  |
| createdAt | datetime |  |  |  |
| updatedAt | datetime |  |  |  |
| isDeleted | boolean |  |  |  |

### `category_groups` (`CategoryGroups`)
| Column | Type | PK | Nullable | References |
| --- | --- | --- | --- | --- |
| id | integer | ✓ |  |  |
| name | text |  |  |  |
| sortOrder | integer |  |  |  |
| isDeleted | boolean |  |  |  |

### `categories` (`Categories`)
**DAO:** `CategoriesDao` — `lib/core/database/daos/categories_dao.dart`
| Column | Type | PK | Nullable | References |
| --- | --- | --- | --- | --- |
| id | integer | ✓ |  |  |
| groupId | integer |  |  | CategoryGroups |
| name | text |  |  |  |
| rollover | boolean |  |  |  |
| goalAmountCents | integer |  | ✓ |  |
| goalDate | datetime |  | ✓ |  |
| goalType | text |  | ✓ |  |
| sortOrder | integer |  |  |  |
| createdAt | datetime |  |  |  |
| updatedAt | datetime |  |  |  |
| isDeleted | boolean |  |  |  |

### `monthly_budgets` (`MonthlyBudgets`)
**DAO:** `BudgetDao` — `lib/core/database/daos/budget_dao.dart`
| Column | Type | PK | Nullable | References |
| --- | --- | --- | --- | --- |
| id | integer | ✓ |  |  |
| categoryId | integer |  |  | Categories |
| month | text |  |  |  |
| assignedCents | integer |  |  |  |
| rolledOverCents | integer |  |  |  |
| updatedAt | datetime |  |  |  |

### `transactions` (`Transactions`)
**DAO:** `TransactionsDao` — `lib/core/database/daos/transactions_dao.dart`
| Column | Type | PK | Nullable | References |
| --- | --- | --- | --- | --- |
| id | integer | ✓ |  |  |
| accountId | integer |  |  | Accounts |
| categoryId | integer |  | ✓ | Categories |
| amountCents | integer |  |  |  |
| payee | text |  |  |  |
| date | datetime |  |  |  |
| memo | text |  | ✓ |  |
| type | text |  |  |  |
| cleared | boolean |  |  |  |
| recurring | boolean |  |  |  |
| recurringInterval | text |  | ✓ |  |
| nextDueDate | datetime |  | ✓ |  |
| importedFrom | text |  | ✓ |  |
| createdAt | datetime |  |  |  |
| updatedAt | datetime |  |  |  |
| toAccountId | integer |  | ✓ | Accounts |
| isDeleted | boolean |  |  |  |

### `net_worth_snapshots` (`NetWorthSnapshots`)
| Column | Type | PK | Nullable | References |
| --- | --- | --- | --- | --- |
| id | integer | ✓ |  |  |
| date | datetime |  |  |  |
| totalAssetsCents | integer |  |  |  |
| totalLiabilitiesCents | integer |  |  |  |
| netWorthCents | integer |  |  |  |

### `budget_snapshots` (`BudgetSnapshots`)
**DAO:** `BudgetSnapshotsDao` — `lib/core/database/daos/budget_snapshots_dao.dart`
| Column | Type | PK | Nullable | References |
| --- | --- | --- | --- | --- |
| id | integer | ✓ |  |  |
| categoryId | integer |  |  | Categories |
| month | text |  |  |  |
| assignedCents | integer |  |  |  |
| spentCents | integer |  |  |  |
| createdAt | datetime |  |  |  |

### `pending_recurring_queue` (`PendingRecurringQueue`)
**DAO:** `RecurringQueueDao` — `lib/core/database/daos/recurring_queue_dao.dart`
| Column | Type | PK | Nullable | References |
| --- | --- | --- | --- | --- |
| id | integer | ✓ |  |  |
| sourceTransactionId | integer |  |  | Transactions |
| dueDate | datetime |  |  |  |
| createdAt | datetime |  |  |  |


## Firestore Sync

Sync is **one-directional: local → cloud** (no merge/pull from Firestore).

| Firestore Collection | Local Table | Sync Direction |
| --- | --- | --- |
| accounts | accounts | local_to_cloud |
| categoryGroups | category_groups | local_to_cloud |
| categories | categories | local_to_cloud |
| transactions | transactions | local_to_cloud |


## Entity Relationships

- **categories** belong to a **category_groups** (via `groupId`)
- **monthly_budgets** reference a **categories** row (via `categoryId`) and a month string (YYYY-MM)
- **transactions** reference an **accounts** row (via `accountId`) and optionally a **categories** row (via `categoryId`)
- **transactions** may reference a second **accounts** row (via `toAccountId`) for transfers
- **budget_snapshots** reference a **categories** row and a month string
- **pending_recurring_queue** references a **transactions** row (the template recurring transaction)
