# Authentication & Biometric Lock

## What it does
Handles user identity via Firebase Auth (email/Google sign-in) and provides a local biometric lock screen that gates access to the app on app launch or resume. Auth state is exposed as a Riverpod provider.

## User actions
- Sign in with Google or email
- Sign out
- Unlock app with biometrics (fingerprint / face ID)

## Screens and widgets
- `lib/features/auth/biometric_lock_screen.dart`

## Providers
- `lib/features/auth/auth_providers.dart`

## Services
- `lib/features/auth/firebase_auth_service.dart`

## Provider chain
Data flows from screen → provider (`auth_providers.dart`) → DAO → Drift table.
Providers are watched reactively; stream-returning DAO methods push updates automatically.

## Data model
_no direct table access_

## Dependencies on other features
_none_

## Known gaps
_none identified_
