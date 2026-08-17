#!/bin/bash

cd /home/buscamais/htdocs/buscamais.org

# Este script sobe o Rails diretamente (sem passar pelo Dockerfile), então
# precisa recompilar o CSS do Tailwind aqui — senão classes novas usadas no
# código ficam sem estilo até alguém rodar o build manualmente.
bundle exec rails tailwindcss:build

exec bundle exec rails server -b 127.0.0.1 -p 3015
