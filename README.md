# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Feeds RSS

O painel **Admin → Feeds RSS** cadastra fontes RSS/Atom externas. Cada fonte tem
seu próprio intervalo de busca (5 minutos a 24 horas), categoria padrão e autor.

- A verificação roda **a cada minuto dentro do processo do Puma** (`FeedScheduler`).
  Só as fontes cujo intervalo venceu são consultadas.
- As matérias novas entram como **publicadas** por padrão (desmarcável por feed,
  enviando para "aguardando revisão").
- Texto e resumo são sanitizados; a primeira imagem do item vira a capa e é
  baixada para o Active Storage.
- A deduplicação usa o `guid`/`id` do feed e a URL original, então a mesma
  matéria não é importada duas vezes.
- Feed pausado não é consultado; excluir o feed mantém as matérias já importadas.

Comandos manuais:

```sh
bin/rails feeds:sync              # sincroniza as fontes vencidas
bin/rails "feeds:sync_one[1]"     # força uma fonte pelo ID
```

Para desativar o agendador automático (por exemplo, se for usar cron), defina
`FEED_SCHEDULER_DISABLED=1` no ambiente do processo.

