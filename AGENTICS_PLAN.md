# Agentics Plan — MyBudgetApp

Add [GitHub Agentic Workflows](https://github.com/githubnext/agentics) to the Flutter/Firebase finance app.

## Prerequisites

```bash
gh extension install github/gh-aw
```

## Workflows to Add

- [ ] **CI Doctor** — monitors Flutter build CI across Android, Windows, and web platforms
  ```bash
  gh aw add ci-doctor
  ```

- [ ] **Daily Test Improver** — grows Dart/Flutter test coverage for account, transfer, and goals logic
  ```bash
  gh aw add daily-test-improver
  ```

- [ ] **Daily Accessibility Review** — reviews Flutter web accessibility automatically
  ```bash
  gh aw add daily-accessibility-review
  ```

- [ ] **Dependabot PR Bundler** — bundles Flutter/Firebase dep updates into single PRs instead of noise
  ```bash
  gh aw add dependabot-pr-bundler
  ```

- [ ] **Repository Quality Improver** — rotating quality review across code, docs, security, and testing
  ```bash
  gh aw add repository-quality-improver
  ```

- [ ] **Daily Perf Improver** — surfaces Firebase query and render performance bottlenecks
  ```bash
  gh aw add daily-perf-improver
  ```

- [ ] **Issue Triage** — auto-labels incoming issues and PRs
  ```bash
  gh aw add issue-triage
  ```

- [ ] **Plan** (`/plan` command) — breaks big issues into tracked sub-tasks
  ```bash
  gh aw add plan
  ```

## Keep Workflows Updated

```bash
gh aw upgrade
gh aw update
```
