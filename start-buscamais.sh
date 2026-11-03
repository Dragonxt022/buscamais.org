#!/bin/bash
set -euo pipefail

cd /home/buscamais/htdocs/buscamais.org

# Carrega DB_*, SECRET_KEY_BASE e demais variáveis do .env.
set -a
# shellcheck disable=SC1091
. ./.env
set +a
export RAILS_ENV=production

# CSS do Tailwind + assets com digest para produção. O build precisa rodar
# aqui porque o deploy sobe o Rails direto, sem passar pelo Dockerfile.
bundle exec rails tailwindcss:build
bundle exec rails assets:precompile

exec bundle exec rails server -b 127.0.0.1 -p 3015
