# Onboarding

## What it does
First-run flow that walks new users through setting up their first account and initial budget categories so the app is ready to use. Completion state is persisted and controls whether the app shows the main shell or the onboarding screen.

## User actions
- Complete first-time setup wizard
- Add first account
- Accept default budget categories

## Screens and widgets
- `lib/features/onboarding/onboarding_screen.dart`

## Providers
- `lib/features/onboarding/onboarding_providers.dart`

## Services
_none_

## Provider chain
Data flows from screen → provider (`onboarding_providers.dart`) → DAO → Drift table.
Providers are watched reactively; stream-returning DAO methods push updates automatically.

## Data model
| Table | Operations | Reactive? |
| --- | --- | --- |
| accounts | read+write | no |
| categories | read+write | no |

## Dependencies on other features
`accounts`

## Known gaps
- Exact onboarding steps depend on screen implementation detail
