#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FLUTTER="${FLUTTER:-$HOME/flutter/bin/flutter}"
WEB_ROOT="${WEB_ROOT:-/var/www/cool-padel/web}"
DEPLOY_DOMAIN="${DEPLOY_DOMAIN:-130-193-59-193.sslip.io}"
CERTBOT_EMAIL="${CERTBOT_EMAIL:-}"

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
if ! command -v nginx >/dev/null; then
  sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nginx
fi

sudo cp "$ROOT/deploy/nginx-cool-padel.conf" /etc/nginx/sites-available/cool-padel
sudo sed -i "s/server_name .*/server_name ${DEPLOY_DOMAIN};/" /etc/nginx/sites-available/cool-padel
sudo ln -sf /etc/nginx/sites-available/cool-padel /etc/nginx/sites-enabled/cool-padel
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx

echo "==> HTTPS (Let's Encrypt)"
if ! command -v certbot >/dev/null; then
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y certbot python3-certbot-nginx
fi

CERTBOT_ARGS=(--nginx -d "$DEPLOY_DOMAIN" --non-interactive --agree-tos --redirect)
if [[ -n "$CERTBOT_EMAIL" ]]; then
  CERTBOT_ARGS+=(--email "$CERTBOT_EMAIL")
else
  CERTBOT_ARGS+=(--register-unsafely-without-email)
fi

sudo certbot "${CERTBOT_ARGS[@]}" || echo "Certbot failed — check DNS for $DEPLOY_DOMAIN"

echo ""
echo "Done."
echo "  API:  https://${DEPLOY_DOMAIN}/api/v1/health"
echo "  Web:  https://${DEPLOY_DOMAIN}/"
