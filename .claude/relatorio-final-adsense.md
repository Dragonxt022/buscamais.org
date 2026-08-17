# Relatório Final — Busca Mais: preparação para Google AdSense

Data: 2026-08-17
Este relatório segue a estrutura pedida no checklist original. O histórico detalhado, passo a passo, de tudo que foi investigado e alterado está em `.claude/relatorio-fase-1-auditoria.md` — este documento é o resumo executivo final.

---

## 1. Problemas encontrados

**Técnicos/SEO:**
- `robots.txt` sem nenhuma diretiva (nem `Sitemap:`, nem `Disallow:`).
- Categorias vazias apareciam no menu, na home e no `sitemap.xml`, e eram indexáveis.
- `/noticias` renderizava o mesmo conteúdo de `/` — conteúdo duplicado do ponto de vista de SEO.
- Meta description genérica repetida em 6+ páginas institucionais.
- `og:image` da notícia declarava 1200×630 mas servia a imagem no tamanho original — inconsistente com a spec do Open Graph.
- Nenhuma imagem usava `loading="lazy"`; nenhuma usava variantes (WebP/redimensionamento) apesar da gem já estar instalada.
- CSS do Tailwind não era recompilado no deploy real (`start-buscamais.sh` não rodava o build) — bug de infraestrutura que já causou pelo menos uma regressão visual durante este trabalho.

**Editorial/confiança:**
- Informações institucionais não verificáveis: "+50 publicações mensais", "6 editorias cobertas", "equipe de jornalistas" (havia 1 autor no sistema), "milhares de leitores" (2x), horário de atendimento fictício.
- E-mails `contato@buscamais.org` e `privacidade@buscamais.org` exibidos como se fossem caixas monitoradas — não existe sistema de e-mail real, só o formulário lido na interface admin.
- Boletim informativo (newsletter) captura o e-mail mas não salva em lugar nenhum — funcionalidade que finge funcionar. **Ainda não resolvido, ver seção 3.**
- 5 notícias 100% locais de Cujubim estavam categorizadas como "Mundo".
- 2 títulos publicados em CAIXA ALTA (cópia direta de nota oficial sem edição).
- Tags com erro de digitação ("Inalguração "), sem capitalização, e uma tag "Teste" em produção.
- Faltavam as páginas `/politica-editorial` e `/correcoes`, exigidas pelo checklist.
- Estrutura do site (categorias genéricas de portal nacional: Mundo, Tecnologia, Política, Esportes) não refletia o conteúdo real (100% hiperlocal de Cujubim/RO).

**Acessibilidade:**
- Labels do formulário de contato sem `for` associado ao campo.
- Campo de busca da navbar sem `aria-label`.
- Menu de categorias (desktop) só abria com mouse — inacessível via teclado.
- Uso extensivo de `text-gray-400` (contraste ~2.8:1) em textos secundários (datas, metadados) em ~300 pontos do site — abaixo do mínimo recomendado pela WCAG AA (4.5:1). **Identificado, não corrigido — ver seção 3.**

---

## 2. Alterações realizadas

**SEO/técnico:**
- `public/robots.txt` reescrito com `Disallow` para áreas privadas e `Sitemap:`.
- Categorias sem notícia publicada somem do menu, do sitemap e da home; se acessadas diretamente por URL, recebem `noindex`.
- `/noticias` virou uma listagem própria (`NoticiasController#todas`), eliminando o conteúdo duplicado; homepage ganhou botão "Ver mais notícias →".
- Meta description única em home, `/carreiras`, `/privacidade`, `/termos`, `/boletim`, `/mapa-do-site`.
- `og:image`/`twitter:image`/JSON-LD agora usam uma variante real 1200×630, condizente com o que é declarado.
- Todas as imagens de capa convertidas para WebP com tamanho ajustado ao contexto (variam de ~200px a 1920px conforme o uso), com `loading="lazy"` fora da dobra.
- `start-buscamais.sh` agora roda `tailwindcss:build` antes de subir o servidor.

**Estrutura editorial:**
- Removidas todas as afirmações não verificáveis listadas na seção 1 (exceto boletim — ver seção 3).
- Trocados os e-mails "fantasma" por referência única ao formulário de contato (o canal real).
- Criadas `/politica-editorial` e `/correcoes`, com conteúdo real (sem inventar fatos), linkadas no rodapé/mapa do site/sitemap.
- Criado índice `/autores`.
- **Categorias múltiplas implementada** (mudança estrutural): notícia agora pode ter 1 categoria principal + N categorias adicionais (nova tabela `article_categories`). Formulário de editor/admin ganhou seleção múltipla.
- Criadas as categorias Cujubim, Rio Crespo, Ariquemes, Porto Velho, Machadinho do Oeste.
- As 5 notícias mal categorizadas em "Mundo" tiveram a categoria principal corrigida para Cujubim. Outras 9 notícias que mencionam Cujubim ganharam Cujubim como categoria adicional, mantendo a categoria de assunto original (Saúde/Educação/Economia/Política). 1 notícia sobre Ariquemes ganhou Ariquemes como categoria adicional.
- 3 tags corrigidas (typo/capitalização), 1 tag de teste removida de 2 artigos publicados.
- Campo "legenda da imagem" adicionado às notícias (migration + formulário + exibição pública + JSON-LD).
- Campo "área de atuação" adicionado aos autores (migration + formulário admin + exibição pública + JSON-LD).
- Indicação "Atualizado em [data]" nas notícias quando há edição relevante após a publicação.
- `/sobre-nos` reescrita por completo: explica o que é o site, região atendida, como as informações são obtidas, quem produz o conteúdo (sem inventar equipe), com links para política editorial e correções. Ano de fundação corrigido para 2025 (informado pelo usuário).
- Removida toda linguagem de "portal nacional genérico" (ex.: "para o leitor brasileiro") — confirmado que não resta nenhuma menção assim no site.

**Homepage (redesign a pedido do usuário):**
- Hero virou slider automático dos 5 destaques mais recentes (antes só 1 aparecia, e 9 das 10 notícias marcadas como destaque não apareciam em lugar nenhum).
- Blocos por categoria uniformizados (4 cards do mesmo tamanho, antes 1 gigante + 3 pequenos).
- Setas do slider redesenhadas; título/resumo do hero limitados a 2 linhas (corrigindo sobreposição com o menu).
- Banners de anúncio direto com tamanho máximo por formato.

**Acessibilidade:**
- Labels do formulário de contato associados via `for`; `aria-label` no campo de busca.
- Menu de categorias (desktop) convertido de `<button>` para `<a>` real, navegável por teclado (Tab + Enter), com `focus`/`blur`/`focusin`/`focusout` cobrindo a abertura/fechamento do painel.

---

## 3. Alterações que NÃO foram feitas (exigiam decisão humana ou dado que não tenho)

- **Boletim informativo**: continua capturando e-mail sem salvar em lugar nenhum. Precisa de decisão: implementar de verdade ou remover a seção.
- **Contraste de texto secundário** (`text-gray-400`, ~300 ocorrências em 62 arquivos): identificado, não corrigido — é uma mudança de sistema de design com risco de regressão visual que eu não consigo verificar sem navegador neste ambiente. Recomendo tratar como projeto à parte, testado visualmente.
- **Content-Security-Policy**: está desativada. Não ativei porque o site usa Stripe Checkout e Google OAuth, e uma CSP mal configurada pode quebrar login/pagamento silenciosamente — não tenho como testar esses fluxos ponta a ponta neste ambiente. Recomendo implementar com testes ao vivo do checkout e do login logo em seguida.
- **Fases 11, 12, 13 do checklist** (conteúdo evergreen, guias de concursos, serviços públicos): não iniciadas. Dependem de dados públicos reais (endereços de UBS/escolas, telefones, população atualizada, etc.) que não tenho disponíveis e não vou inventar. O usuário confirmou que o Busca Mais é um jornal descentralizado, sem sede física — isso não bloqueia essas fases (são sobre serviços do município, não do jornal), só preciso das fontes de dados quando/se o usuário quiser avançar nelas.
- **Classificação de originalidade Tipo A/B/C (Fase 10)**: foi feita como análise (ver relatório da Fase 1), mas por decisão do usuário não adicionei citação de fonte às notícias Tipo C.
- **UX cross-device real (Fase 23)**: não há navegador/Playwright disponível neste servidor; validei responsividade pelas classes Tailwind (`sm:`/`md:`/`lg:` usadas consistentemente) e pelos ajustes que o próprio usuário reportou via screenshot, mas não testei fisicamente em Android/iPhone/tablet.
- **Google Search Console (Fase 30)**: acesso externo, só o usuário pode fazer.
- **"área de atuação"/"legenda de imagem" retroativos**: os campos novos existem mas estão vazios nas notícias/autores já publicados — ninguém preencheu retroativamente (opcional, não obrigatório).

---

## 4. Conteúdos que precisam de revisão manual

- 2 notícias com título em CAIXA ALTA ("PREFEITURA DE CUJUBIM DIVULGA HOMOLOGAÇÃO...", "PREFEITURA DE CUJUBIM CONVOCA CANDIDATOS...") — sugiro reescrever em title case.
- 4 notícias classificadas como Tipo C (reprodução próxima de comunicado oficial) — ver relatório da Fase 1 para a lista e sugestões de como adicionar contexto.
- "4ª Cavalgada do Fundão" — não confirmei se "Fundão" é localidade de Cujubim; se for, vale adicionar a categoria Cujubim manualmente.

---

## 5. URLs novas

- `/noticias` (antes existia mas duplicava a home; agora é uma listagem própria)
- `/politica-editorial`
- `/correcoes`
- `/autores`
- `/categoria/cujubim`
- `/categoria/ariquemes`
- `/categoria/rio-crespo`, `/categoria/porto-velho`, `/categoria/machadinho-do-oeste` (existem mas ficam ocultas/sem indexação até terem conteúdo)

---

## 6. URLs removidas/noindex

- Nenhuma URL foi removida.
- Categorias sem notícia publicada (hoje: Esportes, Tecnologia, Rio Crespo, Porto Velho, Machadinho do Oeste, e "Mundo" que ficou vazia após a recategorização) recebem `noindex` se acessadas diretamente, e não aparecem no menu/sitemap. Justificativa: conteúdo vazio não deve ser indexado (Fase 2 do checklist); voltam a aparecer automaticamente assim que tiverem 1+ notícia publicada.

---

## 7. SEO

- **Sitemap**: `/sitemap.xml` inclui apenas URLs válidas e indexáveis — notícias publicadas, categorias com conteúdo, autores com notícias, páginas institucionais. `lastmod` correto nas notícias.
- **Robots**: diretivas reais adicionadas, sitemap referenciado, áreas privadas listadas (defesa em profundidade — essas áreas já exigem login, não eram indexáveis mesmo antes).
- **Canonical**: presente em todas as páginas, verificado sem duplicidade entre `/` e `/noticias`.
- **Metadata**: title e meta description únicos em todas as páginas institucionais e de notícia.
- **Schema (JSON-LD)**: `NewsArticle` completo (headline, image com caption quando houver, datePublished, dateModified, author, publisher); `Person` do autor com bio/área de atuação quando preenchidos.
- **Indexação**: nenhuma página de baixo valor (busca interna, categorias vazias, áreas administrativas) é indexável.

---

## 8. Performance

- Implementadas variantes WebP redimensionadas para cada contexto (hero, cards, thumbnails) — reduziu uma imagem testada de 3,17 MB para 146 KB.
- `loading="lazy"` em todas as imagens fora da primeira dobra.
- **Não medido**: Core Web Vitals reais (Lighthouse/PageSpeed Insights) — não há ferramenta disponível neste ambiente para rodar contra o site ao vivo. Recomendo rodar isso após o deploy das mudanças.

---

## 9. AdSense

**O Busca Mais está estruturalmente pronto para uma nova solicitação de avaliação do Google AdSense?**

### SIM, com ressalvas.

O que já está pronto: robots.txt e sitemap corretos, sem categorias vazias expostas, sem informações falsas/exageradas, páginas institucionais completas (Sobre Nós, Contato, Privacidade, Termos, Política Editorial, Correções, Autores) e acessíveis pelo rodapé, autores identificados, estrutura editorial das notícias completa, HTTPS ativo, navegação clara, conteúdo original suficiente (a maioria das notícias tem apuração ou contextualização própria, não é cópia crua).

O que falta antes de eu marcar como "SIM" sem ressalva:
1. **Rodar Google Search Console** (Fase 30) — validar sitemap, checar páginas indexadas/excluídas, erros e Core Web Vitals reais. Só o usuário tem acesso.
2. **Resolver o boletim informativo** — hoje finge capturar o e-mail. Um recrutador de conteúdo humano do AdSense que teste o formulário vai notar.
3. **Medir Core Web Vitals reais** com PageSpeed Insights após o deploy — as otimizações foram feitas, mas não confirmadas com uma métrica real.
4. Recomendo pequenas revisões editoriais manuais (seção 4) antes de solicitar, mas não são bloqueadores.

Nada do que falta é trabalho grande — são 1 decisão de produto (boletim) + verificações externas que exigem acesso que só o usuário tem.
