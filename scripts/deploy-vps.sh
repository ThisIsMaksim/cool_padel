#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FLUTTER="${FLUTTER:-$HOME/flutter/bin/flutter}"
WEB_ROOT="${WEB_ROOT:-/var/www/cool-padel/web}"

echo "==> Backend: install & build"
cd "$ROOT/backend"
npm ci
npm run build

echo "==> MongoDB container (skip if already running)"
if ! sudo docker ps --format '{{.Names}}' | grep -q '^cool_padel_mongo$'; then
  sudo docker run -d --name cool_padel_mongo \
    -p 127.0.0.1:27017:27017 \
    -v cool_padel_mongo:/data/db \
    --restart unless-stopped \
    mongo:7 || true
fi

echo "==> PM2: API"
if ! command -v pm2 >/dev/null; then
  sudo npm install -g pm2
fi
pm2 startOrReload "$ROOT/backend/ecosystem.config.cjs" --update-env
pm2 save

echo "==> Flutter web build"
cd "$ROOT"
"$FLUTTER" pub get
"$FLUTTER" build web --release --dart-define=API_BASE_URL=/api/v1

echo "==> Deploy static files"
sudo mkdir -p "$WEB_ROOT"
sudo rsync -a --delete "$ROOT/build/web/" "$WEB_ROOT/"

echo "==> Nginx"
if command -v nginx >/dev/null; then
  sudo cp "$ROOT/deploy/nginx-cool-padel.conf" /etc/nginx/sites-available/cool-padel
  sudo ln -sf /etc/nginx/sites-available/cool-padel /etc/nginx/sites-enabled/cool-padel
  sudo rm -f /etc/nginx/sites-enabled/default
  sudo nginx -t
  sudo systemctl reload nginx
else
  echo "nginx not installed — skip. Install: sudo apt install nginx"
fi

echo "Done. API: http://127.0.0.1:3000/api/v1/health"
echo "Web:  http://$(hostname -I | awk '{print $1}')/"
