#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-stable}"
FLUTTER_DIR="${FLUTTER_DIR:-$PWD/.flutter}"

echo "==> Installing Flutter ($FLUTTER_VERSION) into $FLUTTER_DIR"
if [ ! -d "$FLUTTER_DIR/bin" ]; then
  git clone https://github.com/flutter/flutter.git -b "$FLUTTER_VERSION" --depth 1 "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

echo "==> Flutter version"
flutter --version

echo "==> Enabling web"
flutter config --enable-web

echo "==> Resolving dependencies"
flutter pub get

echo "==> Building web release"
flutter build web --release --no-wasm-dry-run --dart-define=API_BASE_URL=/api/v1

echo "==> Done: build/web"
