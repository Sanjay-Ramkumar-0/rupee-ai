# Rupee AI

> A financial operating system for middle-class India.
> Simple. Trustworthy. Emotionally intelligent.

Rupee AI is an AI-assisted personal finance system designed for India’s UPI-first payment ecosystem.

The core problem it aims to solve is simple:

# “Where is my money going?”

Traditional finance apps still rely heavily on manual entry, fragmented dashboards, or outdated transaction handling systems.

Rupee AI explores a different direction:
an intelligent, privacy-focused finance layer that helps users understand spending behavior, budgets, savings, and financial habits with minimal friction.

The project is currently being developed as a working prototype using Flutter, Riverpod, Isar DB, and experimental transaction intelligence systems.

---

# Why Rupee AI Exists

India’s digital payments ecosystem has transformed rapidly through:

* UPI
* QR payments
* banking notifications
* wallet systems
* real-time payment apps

But personal finance management still feels:

* manual
* disconnected
* difficult to understand
* emotionally stressful for many users

Rupee AI is designed to explore:

* intelligent spending awareness
* automated financial organization
* privacy-first finance systems
* AI-assisted financial understanding
* emotionally aware money management

The focus is not just accounting.

It is helping users build a healthier relationship with money.

---

# Current MVP Features (v1)

## Finance Dashboard

* Remaining balance tracking
* Today’s spending overview
* Category-based spending visualization
* Smart alerts and summaries

## Expense Tracking

* Transaction history timeline
* Search and filters
* Included/excluded transactions
* Dynamic remaining balance calculation

## Budgeting System

* Category-wise budgets
* Budget color states
* Savings goal tracking
* Spending progress visualization

## AI Insight Layer (Experimental)

* Financial health score
* Monthly spending summaries
* Spending behavior cards
* AI-oriented recommendation exploration

## Offline-First Storage

* Persistent local storage using Isar DB
* Fast transaction retrieval
* Local-first privacy architecture

## Experimental Transaction Detection

* Simulated SMS expense parsing
* Notification-based transaction understanding
* Research toward real-time automation

---

# Screenshots

*Add application screenshots here*

Example:

```md
![Dashboard](screen_shots/dashboard.png)
![Budget](screen_shots/budget.png)
![History](screen_shots/history.png)
```

---

# Tech Stack

* Flutter
* Dart
* Riverpod
* Isar Database
* Android Notification Services

---

# Architecture

```text
SMS / Notifications
        ↓
Transaction Parser
        ↓
Categorization Engine
        ↓
Riverpod State Layer
        ↓
Isar Database
        ↓
Dashboard + AI Insights
```

---

# Project Structure

```text
lib/
  app.dart                 # Root app + onboarding gate
  core/theme/              # Design system
  core/widgets/            # Reusable UI components
  models/                  # Transaction, Budget, Profile
  providers/               # Riverpod state management
  screens/                 # Main screens + navigation
  services/                # Isar and future integrations
```

---

# Financial Formula

```text
Remaining Balance =
Monthly Income − Included Expenses
```

---

# Database Model

Transactions are persisted locally using Isar.

## TransactionModel

| Field     | Type     |
| --------- | -------- |
| id        | Id       |
| amount    | double   |
| merchant  | String   |
| category  | String   |
| timestamp | DateTime |
| balance   | double?  |
| smsBody   | String?  |
| included  | bool     |

## IsarService Methods

* addTransaction()
* getTransactions()
* deleteTransaction()

---

# Installation

## Clone Repository

```bash
git clone <repository-url>
cd rupee-ai
```

---

## Install Dependencies

```bash
flutter pub get
```

---

## Generate Isar Schema

```bash
chmod +x tool/generate_isar.sh
./tool/generate_isar.sh
```

---

## Run Application

```bash
flutter run
```

---

# Manual Isar Code Generation

```bash
cd tool/isar_codegen

dart pub get

dart run build_runner build --delete-conflicting-outputs

cp lib/transaction_model.g.dart ../../lib/models/
```

---

# Important Note

`isar_generator` is isolated under:

```text
tool/isar_codegen/
```

This avoids analyzer conflicts with:

* flutter_riverpod 3
* Flutter dependency resolution

---

# Privacy

Rupee AI is being designed with a local-first privacy philosophy.

Current prototype behavior:

* Financial data is stored locally using Isar DB
* No bank credentials are collected
* No cloud sync is enabled
* Notification parsing is experimental and user-controlled

---

# Current Limitations

* No direct bank integration
* SMS parsing accuracy varies across banks
* Notification formats differ between apps
* AI insight layer is currently experimental
* Real-time transaction detection is still under research

---

# Roadmap

## Short-Term Goals

* Real SMS parsing
* Better transaction categorization
* Improved dashboard analytics
* IsarService integration across providers

## Future Research Directions

* AI finance assistant
* UPI-native transaction intelligence
* Privacy-preserving AI systems
* Behavioral finance recommendations
* Regional language support
* Intelligent automation systems

---

# Vision

Rupee AI is an exploration into what a modern financial operating system for India could become:

* intelligent
* simple
* privacy-conscious
* emotionally aware
* accessible to everyday users

---

# Status

Currently in active prototype development.

---

# Run Locally

```bash
flutter pub get
flutter run
```

---

# License

MIT License

---

# Author

Sanjay Ramkumar

ECE Student • AI & Systems Enthusiast

LinkedIn:
[www.linkedin.com/in/sanjay-ramkumar-5b954031b](http://www.linkedin.com/in/sanjay-ramkumar-5b954031b)
