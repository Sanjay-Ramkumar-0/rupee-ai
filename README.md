# Rupee AI

A financial operating system for middle-class people in India — simple, trustworthy, and emotionally intelligent.

**Core question answered in seconds:** *Where is my money going?*

## MVP (v1)

- Monthly income setup (no bank integration)
- Home dashboard with remaining balance, today’s spend, category bars, smart alerts
- SMS categorization flow (demo via “Simulate SMS expense”)
- History timeline with search and filters
- Budget tracking with color states and savings goals
- AI insights shell (health score, monthly summary, behavior cards)
- Profile: custom categories, privacy, excluded transactions

## Run

```bash
flutter pub get
flutter run
```

## Isar setup commands

After cloning or changing `TransactionModel` fields:

```bash
# 1. Install app dependencies
flutter pub get

# 2. Regenerate Isar schema (isar_generator is in tool/isar_codegen/)
chmod +x tool/generate_isar.sh
./tool/generate_isar.sh

# 3. Run the app (Isar initializes in main.dart)
flutter run
```

Optional — run codegen manually:

```bash
cd tool/isar_codegen
dart pub get
dart run build_runner build --delete-conflicting-outputs
cp lib/transaction_model.g.dart ../../lib/models/
```

> **Note:** `isar_generator` cannot live in the main `pubspec.yaml` alongside `flutter_riverpod` 3 (analyzer version conflict). Codegen uses the isolated package under `tool/isar_codegen/`.

## Architecture

```
lib/
  app.dart                 # Root + onboarding gate
  core/theme/              # Calm design system
  core/widgets/            # Reusable UI blocks
  models/                  # Transaction, Budget, Profile
  providers/               # Riverpod state + income formula
  screens/                 # 5-tab shell + detail screens
```

**Remaining balance** = Monthly income − included expenses

## Isar database

Transactions are persisted with **Isar** (`lib/models/transaction_model.dart`, `lib/services/isar_service.dart`).

| Field | Type |
|-------|------|
| id | `Id` (auto-increment) |
| amount | `double` |
| merchant | `String` |
| category | `String` |
| timestamp | `DateTime` |
| balance | `double?` |
| smsBody | `String?` |
| included | `bool` |

`IsarService` methods: `addTransaction`, `getTransactions`, `deleteTransaction`.

**Regenerate schema** after changing `TransactionModel` (see commands below).

## Next steps

- Wire `another_telephony` for real SMS parsing
- Load/save transactions via `IsarService` in `finance_notifier`
- Regional languages (Tamil, Hindi, Telugu, Kannada)
- AI chat backend
