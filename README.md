# Money in Sight

A personal finance app that helps you visualize where your money goes and manage it with zero-based budgeting.

## Features

- **Zero-based budgeting** — assign every dollar to a category
- **Transaction tracking** — log expenses, income, and transfers
- **Recurring transactions** — mark transactions as weekly/monthly/yearly; due items surface as a banner with one-tap confirm or skip
- **Budget rollover** — optionally carry unused surplus from each category into the next month
- **Budget rebalancing** — auto-detect overspent categories and get suggested moves from surplus categories; apply with one tap
- **Budget history** — per-month snapshots with a trend chart (budgeted vs actual) and expandable category breakdown
- **Accounts** — track multiple accounts with live running balances
- **Savings goals** — set goals and track progress
- **Analytics** — charts showing spending breakdown, income vs expenses, and budget history trends
- **CSV import** — import transactions from your bank
- **Cloud sync** — optional Firebase sync across devices
- **Biometric lock** — secure access with fingerprint / face unlock
- **Offline-first** — fully functional without internet

## Tech Stack

Flutter · Drift (SQLite) · Riverpod · Firebase Auth + Firestore · fl_chart · local_auth

## Getting Started

```bash
flutter pub get
flutter run
```

## Running Tests

```bash
flutter test
```
