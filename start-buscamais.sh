#!/bin/bash

cd /home/buscamais/htdocs/buscamais.org

exec bundle exec rails server -b 127.0.0.1 -p 3015
