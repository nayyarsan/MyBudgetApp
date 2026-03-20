# Settings

## What it does
App settings screen. Allows users to configure preferences such as currency display, theme, and manage their account (sign out, delete data).

## User actions
- Change currency or number format
- Toggle dark/light theme
- Sign out
- Trigger manual data sync

## Screens and widgets
- `lib/features/settings/settings_screen.dart`

## Providers
_none_

## Services
_none_

## Provider chain
Data flows from screen → provider (`settings_providers.dart`) → DAO → Drift table.
Providers are watched reactively; stream-returning DAO methods push updates automatically.

## Data model
_no direct table access_

## Dependencies on other features
`auth`, `sync`

## Known gaps
- Settings screen detail depends on runtime implementation
