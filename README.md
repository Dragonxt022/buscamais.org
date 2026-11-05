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
  enviando para "aguardando revisão"). Com a reescrita por IA ativa, uma falha
  da IA também envia o item para revisão.
- Texto e resumo são sanitizados; a primeira imagem do item vira a capa e é
  baixada para o Active Storage.
- Com **Reescrever com IA** marcado, o texto do feed é usado só como pauta e a
  matéria publicada é a versão original gerada pelo Ollama.
- A deduplicação usa o `guid`/`id` do feed e a URL original, então a mesma
  matéria não é importada duas vezes.
- Feed pausado não é consultado; excluir o feed mantém as matérias já importadas.

O botão **Sincronizar** do painel enfileira a importação em segundo plano
(`FeedSyncJob`), porque a reescrita com IA pode levar alguns minutos.

Comandos manuais:

```sh
bin/rails feeds:sync                     # sincroniza as fontes vencidas
bin/rails "feeds:sync_one[1]"            # força uma fonte pelo ID
bin/rails "feeds:reescrever[20]"         # reescreve 20 matérias pendentes
bin/rails "feeds:reescrever[50,3]"       # 50 matérias pendentes do feed 3
```

Para desativar o agendador automático (por exemplo, se for usar cron), defina
`FEED_SCHEDULER_DISABLED=1` no ambiente do processo.

## Reescrita automática com IA (Ollama)

As matérias capturadas via RSS podem ser transformadas em artigos originais pela
IA local do [Ollama](https://ollama.com), seguindo a skill `reescrita-materias.md`.

### No servidor

```sh
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.1:8b          # ou outro modelo disponível
ollama serve                     # mantenha rodando
```

Se o Rails roda em outro container/máquina, exponha o Ollama na rede
(`OLLAMA_HOST=0.0.0.0 ollama serve`) e informe a URL interna no painel.

### No painel

1. Acesse **Admin → Configurações → Reescrita com IA — Ollama**.
2. Confira a URL (padrão `http://localhost:11434`) e informe o modelo baixado.
3. Deixe **Ativar reescrita automática** ligado.
4. Em **Admin → Feeds RSS**, cada fonte tem a opção **Reescrever com IA**.

Variáveis de ambiente opcionais (usadas quando o painel não está preenchido):

| Variável | Padrão | Descrição |
| --- | --- | --- |
| `OLLAMA_URL` | `http://localhost:11434` | Endereço do Ollama |
| `OLLAMA_MODEL` | — | Modelo usado na reescrita |
| `OLLAMA_TIMEOUT` | `300` | Tempo máximo de leitura, em segundos |
| `OLLAMA_NUM_CTX` | `8192` | Janela de contexto do modelo |
| `OLLAMA_NUM_PREDICT` | `1500` | Máximo de tokens gerados na resposta |
| `REESCRITA_DISABLED` | — | `1` desliga a reescrita no processo |

### Comportamento

- O texto do feed é limpo (scripts, imagens e créditos da origem) antes de ir
  para a IA.
- A IA devolve título, linha fina, ângulo, palavra-chave, tags e HTML do corpo.
- O sistema valida tamanho e **similaridade com o original** (5-gramas). Texto
  parecido demais é recusado.
- Reescrita válida segue a opção **Publicar automaticamente** do feed.
- Se a reescrita estiver ligada, mas a IA estiver sem modelo ou falhar, a matéria
  entra como **aguardando revisão** com o texto original — nunca é publicada copiada.
- Se a reescrita estiver desligada (no feed ou no painel), vale o comportamento
  antigo de importação direta.
- Matérias reescritas sempre exibem o crédito e o link da fonte original.

### Reprocessar matérias existentes

No painel **Admin → Feeds RSS** há o card **Reprocessar matérias com IA**:

- escolha uma fonte (ou **Todas as fontes**) e a quantidade (até 100);
- o sistema reescreve apenas matérias importadas que ainda estão com o texto
  original (`nil`, `desativada` ou `falhou`);
- matérias já reescritas ficam de fora — clique de novo para continuar o lote;
- o botão **Reescrever com IA** também aparece na tela de cada artigo (admin e
  área do editor), inclusive para forçar uma nova versão; ele funciona mesmo
  com a reescrita automática desligada, desde que o modelo esteja configurado;
- o processamento roda em segundo plano e o status aparece no badge de cada
  matéria: `Reescrevendo…`, `Reescrita por IA`, `IA falhou — revisar` ou
  `Importação direta`;
- matérias que falharam são tentadas de novo nos próximos lotes, mas as ainda
  nunca processadas têm prioridade.

> A URL (slug) das matérias já publicadas é preservada durante o
> reprocessamento para não quebrar links indexados.

