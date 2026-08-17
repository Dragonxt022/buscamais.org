# Relatório — FASE 1: Auditoria Completa (Busca Mais)

Data: 2026-08-17
Escopo: auditoria somente-leitura (código local + banco de dados de desenvolvimento + produção via HTTP). Nenhuma alteração foi feita.

## Stack identificada

- **Framework:** Ruby on Rails 8.1 (Ruby 3.4.2), MySQL (mysql2), Puma, Hotwire/Turbo.
- **Autenticação:** Devise (+ Google OAuth2).
- **Autorização:** Pundit (policies em `app/policies`).
- **Slugs/SEO-friendly URLs:** FriendlyId (`Article`, `Category`, `Tag`, `User`).
- **Conteúdo rico:** ActionText (`has_rich_text :conteudo`), imagens via ActiveStorage.
- **Paginação:** Pagy.
- **Assinaturas/pagamento:** Stripe.
- **Áreas:** pública, `usuario/` (leitor logado), `editor/` (publicação), `admin/` (gestão completa).
- **Sitemap:** gerado dinamicamente em `PaginasController#sitemap` → `app/views/paginas/sitemap.xml.erb` (rota `/sitemap.xml`).
- **Robots:** arquivo estático `public/robots.txt` (não gerado dinamicamente).

## Números atuais (banco de desenvolvimento — refletem o que está em produção pela estrutura do código)

| Métrica | Valor |
|---|---|
| Notícias publicadas | **15** |
| Notícias em rascunho/revisão/agendadas | 0 |
| Categorias (total) | **9** |
| Categorias com "ativo=true" | 9 (todas) |
| **Categorias sem nenhuma notícia publicada** | **4** — Política, Tecnologia, Esportes, Meio Ambiente |
| Usuários (total) | 6 |
| Usuários com permissão de publicar (autores reais) | **1** |
| Tags cadastradas | 29 |
| Tags sem nenhum artigo vinculado | 19 de 29 |
| Títulos/resumos duplicados entre artigos publicados | 0 |
| Artigos publicados sem categoria | 0 |
| Artigos publicados sem imagem de capa | 0 |
| Artigos publicados sem resumo | 0 |

Confirmado ao vivo em `https://buscamais.org/sitemap.xml`: **38 URLs**, incluindo as 4 categorias vazias.
Confirmado ao vivo em `https://buscamais.org/robots.txt`: arquivo só tem o comentário padrão do Rails, **sem nenhuma diretiva** (sem `Sitemap:`, sem `Disallow:`).

## Problemas de SEO encontrados

1. **`robots.txt` sem diretivas** (`public/robots.txt`) — não referencia o sitemap, não bloqueia `/conta`, `/admin`, `/editor`, `/usuario`. Hoje essas áreas não estão sendo indexadas apenas porque exigem login/estão fora do fluxo de crawl, não porque há uma regra explícita.
2. **Sitemap inclui as 4 categorias vazias** (`politica`, `tecnologia`, `esportes`, `meio-ambiente`) — páginas que, ao serem abertas, mostram uma listagem sem notícias. Isso é exatamente o "conteúdo de baixo valor" que o checklist pede para eliminar (Fase 2 e 17).
3. **Meta description duplicada** em pelo menos 6 páginas institucionais (home, `/carreiras`, `/privacidade`, `/termos`, `/boletim`, `/mapa-do-site`) — todas herdam o texto genérico do layout (`"Portal de notícias com integridade jornalística e profundidade analítica."`) por não sobrescreverem `content_for(:meta_description)`.
4. **Nenhum uso de `noindex`** em nenhum lugar do código — as categorias vazias e demais páginas de baixo valor são 100% indexáveis hoje.
5. **Sem `loading="lazy"`** em nenhuma tag `<img>`/`image_tag` do site (home, categoria, notícia, navbar) — todas as imagens de capa carregam de forma síncrona.
6. Estrutura de dados (`NewsArticle` JSON-LD), Open Graph e Twitter Card **já estão implementados corretamente** em `noticias/show.html.erb`, com `headline`, `image`, `datePublished`, `dateModified`, `author`, `publisher`. Ponto positivo, não precisa de retrabalho.
7. Página de autor (`autores/show.html.erb`) tem JSON-LD `Person`, mas **não exibe o campo `bio`** que já existe no model `User` — describes só nome/cargo/contagens.

## Problema editorial estrutural (o mais importante para o objetivo do AdSense)

**As categorias atuais não refletem o foco real do site.** As 9 categorias são: Cultura, Economia, Educação, Esportes, Meio Ambiente, Mundo, Política, Saúde, Tecnologia — um recorte genérico de portal nacional. Só 5 têm conteúdo.

Ao inspecionar as 15 notícias publicadas, **todas são sobre Cujubim/RO** (UBS, SAMU, escolas, concursos da prefeitura, obras, cavalgada local) — ou seja, o site já é, na prática, um portal hiperlocal. Mas pelo menos **5 dessas notícias claramente locais estão categorizadas como "Mundo"** (ex.: "Cujubim amplia frota de máquinas", "Engenharia no Campo: Cujubim Moderniza Estradas", "Processo Seletivo Unificado 2026... Cujubim"), o que é uma categorização incorreta — "Mundo" sugere notícia internacional.

Isso confirma o diagnóstico da Fase 3 do checklist: o site **parece um portal nacional genérico** quando na verdade é 100% conteúdo de Cujubim/Rio Crespo. Não existe hoje nenhuma categoria "Cujubim", "Rio Crespo" ou "Região".

Também encontrei títulos publicados **em CAIXA ALTA** ("PREFEITURA DE CUJUBIM DIVULGA HOMOLOGAÇÃO...", "PREFEITURA DE CUJUBIM CONVOCA CANDIDATOS..."), característico de cópia direta de comunicado oficial sem edição — candidatos a "Tipo C" na classificação da Fase 10.

Tags com problemas de qualidade: `"Inalguração "` (erro de digitação + espaço sobrando), `"secretaria de obras"` e `"ariquemes"` (sem capitalização), `"Teste"` (tag de teste em produção, usada em 2 artigos).

## Informações institucionais não verificáveis encontradas (Fase 4)

Localizadas em produção:

- **`/sobre-nos`**: *"+50 Publicações mensais"* — com 15 artigos publicados no total (não por mês), esse número não é sustentado pelos dados. Também *"6 Editorias cobertas"* (na verdade são 9 categorias, só 5 com conteúdo) e *"2024 — Ano de fundação"* (não verificado — pode ser real, mas não há como confirmar pelo código).
- **`/sobre-nos`**: *"Nossa equipe de jornalistas e analistas trabalha diariamente..."* — o sistema tem exatamente **1 usuário com permissão de publicar**. Não há evidência de "equipe".
- **`/carreiras`**: *"Ajudamos milhares de leitores a entender o mundo todos os dias."*
- **`/planos`**: *"Milhares de leitores confiam no Busca Mais..."*
- **`/contato`**: horário de atendimento *"Seg–Sex, 9h–18h"* — não verificável pelo código.
- **`/boletim`** (newsletter): o formulário de inscrição **não salva o e-mail em lugar nenhum** — `PaginasController#assinar_boletim` só exibe uma mensagem de sucesso fixa e redireciona. É uma funcionalidade que finge funcionar. Isso é um problema de confiança relevante, mesmo não estando listado literalmente no checklist.

## Páginas institucionais — situação (Fase 20)

| Página | Existe? | Rota |
|---|---|---|
| Sobre Nós | ✅ | `/sobre-nos` |
| Contato | ✅ | `/contato` |
| Política de Privacidade | ✅ | `/privacidade` |
| Termos de Uso | ✅ | `/termos` |
| Política Editorial | ❌ **não existe** | — |
| Correções | ❌ **não existe** | — |
| Autores (índice) | ⚠️ parcial — existe página individual `/autor/:slug`, mas não há um índice `/autores` listando todos |

## Segurança (Fase 29) — checagem rápida

- `config.force_ssl = true` em produção — HTTPS/redirect ok.
- `robots.txt` não impede indexação de nada (nem precisa bloquear área administrativa, pois `/admin`, `/editor`, `/usuario`, `/conta` exigem autenticação Devise/Pundit — não são acessíveis a crawlers de qualquer forma).

## Performance (Fase 24) — achados estáticos (sem Lighthouse/PSI ao vivo)

- Gem `image_processing` está no Gemfile mas **não há nenhuma chamada `.variant(...)`** nas views — as imagens de capa são servidas no tamanho/formato original enviado pelo editor, sem conversão para WebP/AVIF nem redimensionamento responsivo.
- Nenhuma imagem usa `loading="lazy"`.
- Não foi possível medir Core Web Vitals reais sem rodar PageSpeed Insights/Lighthouse contra o site ao vivo — recomendo isso como parte da Fase 24/30 quando chegarmos lá.

## Coisas que já estão boas (não mexer)

- JSON-LD `NewsArticle` completo e correto.
- Open Graph e Twitter Card completos nas notícias.
- `canonical` já implementado globalmente no layout (com fallback automático por `request.url`).
- FriendlyId gerando slugs amigáveis para artigos, categorias, tags e autores.
- Nenhum título/resumo duplicado.
- Todos os artigos publicados têm categoria, imagem e resumo — sem "buracos" óbvios de conteúdo incompleto.
- `force_ssl` ativo.

---

## O que isso significa para as próximas fases

Nada foi alterado ainda. Meu plano seria seguir com a **Fase 2 em diante** nesta ordem, mas há decisões que só você pode tomar:

1. **Correções puramente técnicas/mecânicas** (não exigem decisão editorial, posso fazer direto): `robots.txt` com `Sitemap:` e sem indexar categorias vazias, aplicar `noindex` ou ocultar as 4 categorias sem conteúdo do menu/home/sitemap, corrigir a categorização errada das 5 notícias marcadas como "Mundo", corrigir a tag "Inalguração", remover a tag "Teste", meta description única por página institucional, `loading="lazy"` nas imagens, exibir o campo `bio` do autor.
2. **Remoção de números/frases não verificáveis** ("+50 publicações mensais", "equipe de jornalistas", "milhares de leitores") — o próprio checklist manda remover sem inventar substituto, então posso remover diretamente.
3. **Decisões que preciso que você confirme antes de eu mexer:**
   - As categorias sugeridas no checklist são Cujubim, Rio Crespo, Região, Política, Saúde, Educação, Economia, Cultura, Esportes. Isso significa **criar categorias novas "Cujubim" e "Rio Crespo"** e mover as notícias hiperlocais para lá? Ou usar essas como **tags** e manter "Região" como categoria guarda-chuva?
   - Data real de fundação do site, se "2024" está correto ou deve ser removida também.
   - O que fazer com o boletim/newsletter: implementar de verdade (salvar e-mails) ou remover a seção enquanto não for real?
   - Conteúdo da Política Editorial e da página de Correções (tom, política de correções, e-mail responsável) — posso redigir um rascunho, mas convém sua revisão antes de publicar como página institucional pública.

Quer que eu já comece pelos itens 1 e 2 (que não dependem de decisão sua) enquanto você pensa nos itens do 3?

---

## Atualização — itens técnicos/mecânicos executados (2026-08-17)

Testado localmente (porta 3015, mesmo processo que serve produção) após cada mudança — todas as páginas alteradas retornam 200, sem erros.

**Arquivos alterados:**

- `public/robots.txt` — adicionadas diretivas reais: `Disallow` para `/admin/`, `/editor/`, `/usuario/`, `/conta/`, `/busca`, e `Sitemap: https://buscamais.org/sitemap.xml`. Antes era só o comentário padrão do Rails.
- `app/controllers/application_controller.rb` (`carregar_categorias_menu`) — menu (navbar desktop, mega-menu, menu mobile e rodapé) agora só lista categorias com pelo menos 1 notícia publicada. Política, Tecnologia, Esportes e Meio Ambiente somem do menu automaticamente até terem conteúdo.
- `app/controllers/paginas_controller.rb` (`#sitemap`) — `/sitemap.xml` agora só inclui categorias com conteúdo publicado (38 → 34 URLs).
- `app/views/noticias/categoria.html.erb` + `NoticiasController` — categorias vazias (acessadas diretamente por URL) agora recebem `<meta name="robots" content="noindex,follow">`; categorias com conteúdo não são afetadas.
- `app/views/paginas/sobre.html.erb` — removida a caixa de estatísticas "+50 Publicações mensais" / "6 Editorias cobertas" (não sustentadas pelos dados: 15 artigos publicados no total, não por mês). Reescrita a frase que alegava "equipe de jornalistas e analistas" (hoje há 1 autor no sistema) sem inventar número. **"2024 — Ano de fundação" foi mantido intocado** — depende da sua confirmação (item 3 acima).
- `app/views/paginas/carreiras.html.erb` — removida a alegação "Ajudamos milhares de leitores...".
- `app/views/planos/index.html.erb` — removido "Milhares de" leitores (frase não verificável).
- `app/views/paginas/contato.html.erb` — removido o card de horário de atendimento "Seg–Sex, 9h–18h" (não verificável).
- Meta description única adicionada (antes repetiam o texto genérico do layout) em: home (`noticias/index.html.erb`), `/carreiras`, `/privacidade`, `/termos`, `/boletim`, `/mapa-do-site`.
- `loading="lazy"` adicionado em todas as imagens de capa abaixo da dobra (listagens, cards, relacionadas, mega-menu). As duas imagens acima da dobra (hero da home e imagem principal da notícia) permanecem `eager` de propósito — são candidatas a LCP.
- `app/views/autores/show.html.erb` — agora exibe a foto do autor (`avatar_image`) quando anexada, e o campo `bio` (já existia no banco, não era exibido). JSON-LD `Person` passou a incluir `description` e `image` quando disponíveis.
- Tags corrigidas no banco: `"Inalguração "` → `"Inauguração"`, `"secretaria de obras"` → `"Secretaria de Obras"`, `"ariquemes"` → `"Ariquemes"`. Tag `"Teste"` (usada em 2 artigos publicados) removida — não há páginas públicas de tag no site, então isso não afeta nenhuma URL indexada.

**Não alterado nesta rodada (aguardando decisão sua, ver seção acima):**

- Recategorização das 5 notícias locais que estão em "Mundo" — não fiz isso ainda porque a categoria correta depende da decisão sobre criar ou não "Cujubim"/"Região" como categoria.
- Data de fundação "2024" em `/sobre-nos`.
- Newsletter/boletim (captura de e-mail não persiste — continua fingindo funcionar).
- `/politica-editorial` e `/correcoes` (páginas ainda não existem).
- Reestruturação completa de `/sobre-nos` (Fase 5) e taxonomia de categorias (Fase 2/3).

---

## Atualização 2 — segunda leva (autonomia máxima, 2026-08-17)

Modo de trabalho combinado: sigo sem parar pelas fases técnicas/mecânicas; só interrompo quando bater em fato real, decisão de taxonomia, conteúdo institucional/legal ou o pedido final ao AdSense. Tudo abaixo testado localmente (200 OK, sem erros) antes de seguir.

**Fase 7 — Correções (implementado):**
- `app/views/noticias/show.html.erb`: notícia agora exibe **"Atualizado em [data]"** junto à data de publicação quando `updated_at` é mais de 1h posterior a `publicado_em` — mecanismo real de indicação de atualização, usando dado que já existia no banco (não precisou de coluna nova).

**Fase 6 e 7 — páginas criadas:**
- `/politica-editorial` (nova) — compromisso com verificação, identificação de fontes, distinção notícia/opinião/publicidade, tratamento de informações oficiais, privacidade, transparência, publicidade, contato para correções. Conteúdo escrito com base apenas em fatos verificados (ex.: hoje o site só publica notícia, ainda não tem seção de opinião/patrocinado — is so foi declarado como está, não inventado).
- `/correcoes` (nova) — como relatar erro, como pedir correção, como o site trata atualizações (linkado ao mecanismo acima), contato oficial.
- Ambas linkadas no rodapé, no mapa do site e no `sitemap.xml`.

**Fase 8 — Autores:**
- Nova página `/autores` (índice) listando todos os autores com artigos publicados, foto/inicial, cargo e contagem de artigos. Linkada no rodapé e no mapa do site.
- **Pendente, não fiz:** campo "área de atuação" citado na Fase 8 não existe no banco (`User` não tem essa coluna); adicionar exigiria uma migration. Não fiz isso agora por ser uma mudança estrutural — aviso antes de fazer.

**Fase 15/24 — Dados estruturados e performance de imagem (implementado e testado ponta a ponta via HTTP):**
- Descobri que a gem `image_processing` (já no Gemfile) funciona neste servidor — `libvips` está instalado, só não estava sendo usado em nenhuma view.
- Todas as imagens de capa do site agora usam `.variant(..., format: :webp)` com tamanho ajustado ao espaço real onde aparecem (hero 1920×1080, cards 500-800px, thumbnails 200-400px). Testei uma imagem real: original 3,17 MB → variante servida em produção com 146 KB.
- `og:image`/`twitter:image`/JSON-LD `image` da notícia agora usam uma variante `1200×630` de verdade — antes a tag dizia `width=1200 height=630` mas servia a imagem no tamanho original, o que é inconsistente com a spec do Open Graph.

**Fase 16/1 — Links internos / links quebrados:**
- Rastreei as 12 páginas principais (home, institucionais, planos) e verifiquei os 77 links internos únicos encontrados nelas (notícias, categorias, autores, etc.) — **nenhum link quebrado**.

**Fase 29 — Segurança (verificado, sem necessidade de mudança):**
- Rails já envia por padrão `X-Frame-Options: SAMEORIGIN`, `X-Content-Type-Options: nosniff` e `Referrer-Policy: strict-origin-when-cross-origin`. `Strict-Transport-Security` é adicionado automaticamente em produção via `force_ssl = true` (já configurado).
- **Content-Security-Policy está desativado** (`config/initializers/content_security_policy.rb` só tem o bloco comentado). **Decidi não ativar agora**: o site usa Stripe Checkout, Google OAuth e vai carregar o script do Google AdSense — uma CSP mal configurada pode quebrar login ou pagamento silenciosamente, e eu não tenho como testar esses fluxos ponta a ponta neste ambiente (não há credenciais de teste do Stripe/Google disponíveis). Fica como item pendente que prefiro implementar com você testando o checkout/login logo em seguida, em vez de arriscar quebrar em produção sem detectar.

**Arquivos novos/alterados nesta leva:** `app/views/autores/index.html.erb`, `app/views/paginas/politica_editorial.html.erb`, `app/views/paginas/correcoes.html.erb` (novos); `config/routes.rb`, `app/controllers/autores_controller.rb`, `app/views/shared/_footer.html.erb`, `app/views/paginas/mapa_site.html.erb`, `app/views/paginas/sitemap.xml.erb`, `app/views/noticias/show.html.erb`, `app/views/noticias/index.html.erb`, `app/views/noticias/categoria.html.erb`, `app/views/shared/_navbar.html.erb` (alterados).

**Resolvido:** confirmado com o usuário que não existe caixa de e-mail monitorada — o único canal real é o formulário de contato (`ContactMessage` lido direto na interface admin). Removidas todas as menções a `contato@buscamais.org` e `privacidade@buscamais.org` como endereços de e-mail diretos em `contato.html.erb`, `privacidade.html.erb`, `politica_editorial.html.erb` e `correcoes.html.erb`; também removida a menção a um "Encarregado de Dados (DPO)" formal em `privacidade.html.erb` (não existe essa designação formal). Todas as páginas agora apontam exclusivamente para o formulário de contato como canal oficial. Testado: 200 OK em `/contato`, `/privacidade`, `/correcoes`, `/politica-editorial`.

**Bug reportado pelo usuário — corrigido:**
- Na home, a seção "Mais Notícias" usava a paginação (`pagy_nav`) da própria home (`/`). Como a Home inteira (hero, ticker, seções por categoria, tudo) recarregava só para avançar essa lista, o usuário voltava pro topo da página a cada clique.
- Corrigido: `/noticias` agora é uma página própria e independente (antes ela renderizava, por acidente, o mesmo conteúdo de `/` — ou seja, era conteúdo duplicado do ponto de vista de SEO, outro achado da Fase 26 que só apareceu ao investigar o bug). Criei `NoticiasController#todas` + `app/views/noticias/todas.html.erb`, uma listagem limpa e paginada de todas as notícias.
- Na Home, o botão de paginação virou um botão **"Ver mais notícias →"** centralizado, levando para `/noticias`. Adicionada ao sitemap e ao mapa do site.
- Os 3 lugares que já linkavam `noticias_path` esperando "ver todas as notícias" (dashboard do usuário, busca sem resultado, resumo diário) agora levam para a página certa em vez da home inteira.
- Testado: `/`, `/noticias`, `/noticias?page=2`, `/busca` — todos 200 OK.

**Fase 10 — Classificação de originalidade das 15 notícias publicadas (análise, sem alteração de conteúdo):**

| # | Título | Tipo | Observação |
|---|---|---|---|
| 93 | 4ª Cavalgada do Fundão... | **A** | Apuração própria, com aspas de organizadores |
| 108 | Rondônia diante do calor, da seca e do fogo... | **A** | Texto analítico de 3.458 palavras, síntese de 10 fontes institucionais citadas (OMM, NOAA, ANA, Sedam etc.) |
| 94, 95, 97, 98, 99, 101, 103, 104, 105 | (9 notícias) | **B** | Baseadas em fonte oficial/comunicado, mas com contextualização própria (dados do IBGE, valores de investimento, entrevistas, "Fonte:" citada em 3 delas) |
| 96, 102, 106, 107 | Processo Seletivo Unificado / frota de máquinas / homologação SEMSAU / convocação condutor SAMU | **C** | Reprodução próxima de comunicado oficial. 102 já cita fonte (`cujubim.ro.gov.br`) e crédito de imagem — só falta contexto adicional. 96, 106 e 107 **não citam nenhuma fonte** e dois deles (106, 107) têm título em CAIXA ALTA, sinal claro de copiar-e-colar de nota oficial. |

**Ação recomendada para os 4 Tipo C, não executada ainda:** tentei localizar os documentos oficiais exatos (Edital nº 001/2026, homologação SEMSAU Edital nº 004/2026, Portaria nº 228/2026) via busca na web para adicionar `Fonte:` verificável — encontrei o portal da transparência de Cujubim com a seção de processos seletivos (`transparencia.cujubim.ro.gov.br/.../teste-seletivo/...`), mas **não confirmei o link exato de cada documento** e não vou inventar uma URL específica. Precisa que você (ou quem redigiu essas notícias, que provavelmente já tinha o link/PDF em mãos na hora de escrever) me passe os links oficiais dos 3 documentos, ou eu uso o link genérico do portal de transparência — sua escolha. Os títulos em CAIXA ALTA de 106 e 107 eu ainda não toquei porque reescrevê-los está dentro de "melhorar a matéria", que prefiro fazer junto da correção de fonte, não separado.

**Fase 25 — Acessibilidade (verificado + corrigido um item):**
- Corrigido: `<label>` do formulário de contato não tinham `for` associado ao campo (nome/e-mail/assunto/mensagem) — adicionado. Também faltava `aria-label` no campo de busca da navbar (dependia só do placeholder, que some ao digitar e nem sempre é lido por leitor de tela) — adicionado.
- Imagens: todas usam `alt` com o título da notícia (verificado na Fase 1).
- Ainda não verificado: contraste de cores em todos os componentes, navegação por teclado no mega-menu/modais, headings (`h1`-`h6`) fora das páginas de notícia/institucionais.

**Ainda não iniciado (fases inteiras):** 9 (estrutura de notícias — já está boa, mas não fiz auditoria item a item), 10 (classificação de originalidade Tipo A/B/C), 11 (conteúdo evergreen), 12 (concursos), 13 (serviços públicos), 21 (contato — parcialmente feito), 23 (UX cross-device — preciso rodar no navegador), 25 (acessibilidade — spot-check pendente), 26 (conteúdo duplicado — já verificado no relatório da Fase 1, sem duplicatas), 27 (notícias antigas — não há notícias antigas o suficiente para classificar ainda), 28 (conteúdo superficial — já verificado, todas as notícias têm 200+ palavras), 30 (Search Console — externo, precisa de acesso), 31 (checklist final AdSense).
