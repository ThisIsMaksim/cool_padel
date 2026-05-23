# Cool Padel API

NestJS + MongoDB backend for the Cool Padel Flutter app.

Base URL: `http://localhost:3000/api/v1`

## Quick start (VPS / local)

### 1. MongoDB

**Option A — Docker** (if Docker is installed):

```bash
cd backend
docker compose up -d
```

**Option B — system package** (Ubuntu):

```bash
sudo apt update
sudo apt install -y mongodb
sudo systemctl enable --now mongodb
```

### 2. Environment

```bash
cp .env.example .env
# edit JWT_SECRET for production
```

### 3. Install & run

```bash
npm install
npm run build
npm run start:prod
```

For development (watch mode, run in background or separate terminal):

```bash
npm run start:dev
```

### 4. Production with PM2 (recommended on VPS)

```bash
npm install -g pm2
npm run build
pm2 start dist/main.js --name cool-padel-api
pm2 save
pm2 startup
```

Health check: `GET /api/v1/health`

Demo login after seed:

- Email: `maksim@coolpadel.app`
- Password: `123456`

## API endpoints

### Auth
| Method | Path | Auth |
|--------|------|------|
| POST | `/auth/register` | — |
| POST | `/auth/login` | — |
| GET | `/auth/me` | JWT |

### Users
| Method | Path | Auth |
|--------|------|------|
| GET | `/users/me` | JWT |
| PATCH | `/users/me` | JWT |
| GET | `/users/me/favorites` | JWT |
| PATCH | `/users/me/favorites/:playerId/toggle` | JWT |

### Players
| Method | Path | Auth |
|--------|------|------|
| GET | `/players` | JWT |
| GET | `/players/ranking` | JWT |
| GET | `/players/:id` | JWT |

### Games
| Method | Path | Auth |
|--------|------|------|
| GET | `/games?status=inProgress\|finished` | JWT |
| GET | `/games/:id` | JWT |
| POST | `/games` | JWT |
| PATCH | `/games/:id/standard-state` | JWT |
| PATCH | `/games/:id/tournament-state` | JWT |
| PATCH | `/games/:id/deuce-rule` | JWT |
| DELETE | `/games/:id` | JWT |

### Tournaments
| Method | Path | Auth |
|--------|------|------|
| GET | `/tournaments?day=&level=&club=&format=&status=` | JWT |
| GET | `/tournaments/active` | JWT |
| GET | `/tournaments/:id` | JWT |
| POST | `/tournaments/:id/register` | JWT |

## VPS deployment notes

This VPS (**~8 GB RAM, ~92 GB disk**) is enough for:

- MongoDB (~500 MB RAM)
- NestJS API (~100–200 MB RAM)
- Flutter web static server on `:8080`

Suggested layout:

```
:8080  → Flutter web (already running)
:3000  → NestJS API (PM2)
:27017 → MongoDB (localhost only)
```

Put nginx/Caddy in front for HTTPS and route `/api` → `:3000`.

**Security:** bind MongoDB to `127.0.0.1`, set strong `JWT_SECRET`, open only 80/443 publicly.

## Flutter integration (next step)

Point the app to `API_BASE_URL` and replace mock repositories with HTTP client using the same JSON shapes as `lib/storage/game_serialization.dart`.
