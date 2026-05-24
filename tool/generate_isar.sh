#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CODEGEN="$ROOT/tool/isar_codegen"

cd "$CODEGEN"
dart pub get
dart run build_runner build --delete-conflicting-outputs

cp "$CODEGEN/lib/transaction_model.g.dart" "$ROOT/lib/models/transaction_model.g.dart"
echo "Copied transaction_model.g.dart -> lib/models/"
