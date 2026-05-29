#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi
exec gunicorn --bind "${HOST:-127.0.0.1}:${PORT:-8080}" --workers "${WEB_CONCURRENCY:-2}" --threads "${WEB_THREADS:-4}" --timeout 120 wsgi:application
