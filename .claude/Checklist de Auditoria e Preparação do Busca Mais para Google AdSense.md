# Checklist — Busca Mais
## Auditoria, correção editorial, SEO e preparação para Google AdSense

### Objetivo

Preparar o site https://buscamais.org/ para uma nova avaliação do Google AdSense, eliminando sinais de conteúdo de baixo valor, páginas incompletas, categorias vazias, inconsistências editoriais, problemas de confiança e deficiências de SEO.

**IMPORTANTE:** não alterar funcionalidades existentes sem necessidade. Antes de modificar código, entender a arquitetura atual do projeto.

---

# FASE 1 — AUDITORIA COMPLETA

- [ ] Inspecionar toda a estrutura do projeto.
- [ ] Identificar framework, CMS, banco de dados e sistema de templates.
- [ ] Identificar como notícias são cadastradas.
- [ ] Identificar como categorias são cadastradas.
- [ ] Identificar sistema de autores.
- [ ] Identificar geração de sitemap.
- [ ] Identificar geração de robots.txt.
- [ ] Identificar configuração de SEO.
- [ ] Identificar URLs canônicas.
- [ ] Identificar páginas 404.
- [ ] Identificar redirects.
- [ ] Identificar páginas indexáveis.
- [ ] Identificar páginas sem conteúdo.
- [ ] Identificar páginas duplicadas.
- [ ] Identificar páginas com pouco conteúdo.
- [ ] Identificar categorias sem notícias.
- [ ] Identificar tags sem conteúdo.
- [ ] Identificar imagens sem ALT.
- [ ] Identificar links quebrados.
- [ ] Identificar links internos insuficientes.
- [ ] Identificar possíveis problemas de performance.

### Antes de modificar

Gerar um relatório contendo:

- quantidade de notícias;
- quantidade de categorias;
- quantidade de autores;
- páginas públicas;
- páginas indexáveis;
- páginas sem conteúdo;
- categorias vazias;
- URLs duplicadas;
- problemas de SEO encontrados;
- problemas de UX encontrados.

Não executar mudanças destrutivas durante essa etapa.

---

# FASE 2 — CATEGORIAS

O site atualmente possui categorias demais para o volume de conteúdo.

Não deixar categorias vazias visíveis para o usuário.

### Categorias principais sugeridas

- [ ] Cujubim
- [ ] Rio Crespo
- [ ] Região
- [ ] Política
- [ ] Saúde
- [ ] Educação
- [ ] Economia
- [ ] Cultura
- [ ] Esportes

### Regras

- [ ] Não excluir categorias do banco sem necessidade.
- [ ] Categorias sem conteúdo não devem aparecer no menu principal.
- [ ] Categorias sem conteúdo não devem aparecer como destaque na homepage.
- [ ] Categorias vazias não devem gerar páginas indexáveis.
- [ ] Se necessário, aplicar `noindex` às categorias vazias.
- [ ] Não criar conteúdo artificial apenas para preencher categorias.
- [ ] Quando uma categoria atingir quantidade suficiente de conteúdo, ela poderá voltar a ser exibida.

---

# FASE 3 — PÁGINA INICIAL

Auditar completamente a homepage.

### Verificar

- [ ] A homepage deve deixar claro imediatamente o que é o Busca Mais.
- [ ] Mostrar claramente que o portal cobre Cujubim, Rio Crespo e região.
- [ ] Evitar aparência de portal nacional genérico.
- [ ] Não exibir categorias vazias.
- [ ] Não exibir blocos sem conteúdo.
- [ ] Não criar placeholders.
- [ ] Não exibir informações falsas ou exageradas.
- [ ] Melhorar hierarquia visual.
- [ ] Destacar notícias recentes.
- [ ] Criar seção de notícias mais lidas somente se houver dados reais.
- [ ] Criar seção de notícias relacionadas.
- [ ] Melhorar navegação entre conteúdos.
- [ ] Garantir que o usuário consiga chegar a uma notícia importante em poucos cliques.

---

# FASE 4 — REMOVER INFORMAÇÕES INCONSISTENTES

Localizar no site qualquer afirmação que não possa ser comprovada.

Especial atenção para:

> "+50 Publicações mensais"

- [ ] Verificar se essa informação é verdadeira.
- [ ] Se não for comprovável atualmente, remover.
- [ ] Não substituir por outro número inventado.

Também revisar:

- [ ] "equipe de jornalistas"
- [ ] quantidade de colaboradores;
- [ ] quantidade de leitores;
- [ ] quantidade de publicações;
- [ ] números de audiência;
- [ ] frases de autoridade;
- [ ] informações sobre fundação;
- [ ] informações institucionais.

Todas as informações devem representar a realidade atual do projeto.

---

# FASE 5 — PÁGINA SOBRE NÓS

Reestruturar a página "Sobre Nós".

Ela deve explicar claramente:

- [ ] O que é o Busca Mais.
- [ ] Qual região é atendida.
- [ ] Qual é a proposta editorial.
- [ ] Quem produz o conteúdo.
- [ ] Como as informações são obtidas.
- [ ] Como o portal trata correções.
- [ ] Como o leitor pode entrar em contato.
- [ ] Data real de criação do projeto.
- [ ] Política editorial.

Evitar frases genéricas de marketing.

Não inventar jornalistas, equipe ou estrutura que não existam.

---

# FASE 6 — POLÍTICA EDITORIAL

Criar uma página pública:

`/politica-editorial`

Conteúdo mínimo:

- [ ] compromisso com informações verificáveis;
- [ ] identificação das fontes;
- [ ] distinção entre notícia, opinião e publicidade;
- [ ] política para correções;
- [ ] tratamento de informações oficiais;
- [ ] respeito à privacidade;
- [ ] compromisso com transparência;
- [ ] política sobre conteúdo patrocinado;
- [ ] contato para correções.

---

# FASE 7 — CORREÇÕES

Criar página:

`/correcoes`

Explicar:

- [ ] como informar um erro;
- [ ] como solicitar correção;
- [ ] como o Busca Mais trata atualizações;
- [ ] contato oficial para correções.

Nas notícias:

- [ ] permitir indicação de atualização quando houver alteração relevante.
- [ ] Não alterar silenciosamente informações importantes sem registrar atualização.

---

# FASE 8 — AUTORES

Criar/aperfeiçoar sistema de autores.

Cada autor deve possuir página própria.

Exemplo:

`/autor/rodrigo-silva`

A página deve apresentar:

- [ ] nome;
- [ ] foto, quando disponível;
- [ ] descrição verdadeira;
- [ ] área de atuação;
- [ ] lista de artigos publicados;
- [ ] data da última atualização do perfil.

Cada notícia deve mostrar:

- [ ] autor;
- [ ] data de publicação;
- [ ] horário, quando aplicável;
- [ ] data de atualização, quando houver.

Não inventar credenciais profissionais.

---

# FASE 9 — PÁGINAS DE NOTÍCIAS

Cada notícia deve possuir estrutura editorial consistente.

### Estrutura

- [ ] título claro;
- [ ] subtítulo/resumo;
- [ ] imagem principal;
- [ ] legenda da imagem;
- [ ] autoria;
- [ ] data;
- [ ] data de atualização quando necessário;
- [ ] introdução;
- [ ] desenvolvimento;
- [ ] contexto;
- [ ] informações relevantes;
- [ ] fonte;
- [ ] links para documentos oficiais quando existirem;
- [ ] notícias relacionadas;
- [ ] categoria;
- [ ] tags somente quando realmente úteis.

### Importante

Não aumentar artificialmente o tamanho das matérias.

O objetivo é melhorar a utilidade e a profundidade, não simplesmente aumentar a quantidade de palavras.

---

# FASE 10 — ORIGINALIDADE DAS NOTÍCIAS

Identificar matérias que sejam apenas reprodução de comunicados oficiais.

Não apagar automaticamente.

Classificar:

### Tipo A
Conteúdo original/apuração.

### Tipo B
Conteúdo baseado em fonte oficial, mas com contextualização própria.

### Tipo C
Reprodução quase integral de comunicado.

Para Tipo C:

- [ ] reestruturar quando houver autorização/base legítima;
- [ ] identificar claramente a fonte;
- [ ] acrescentar contexto útil;
- [ ] adicionar informações que ajudem o leitor;
- [ ] evitar copiar grandes blocos do texto original.

Quando não houver valor editorial suficiente:

- [ ] considerar `noindex`;
- [ ] ou arquivar conforme a estratégia do site.

Não realizar alterações destrutivas sem relatório.

---

# FASE 11 — CONTEÚDO EVERGREEN

Criar estrutura para conteúdos permanentes.

Priorizar páginas como:

- [ ] Guia de Cujubim.
- [ ] Guia de Rio Crespo.
- [ ] História de Cujubim.
- [ ] História de Rio Crespo.
- [ ] Informações sobre população.
- [ ] Serviços públicos.
- [ ] Saúde.
- [ ] Educação.
- [ ] Concursos.
- [ ] Processos seletivos.
- [ ] Telefones úteis.
- [ ] Eventos.
- [ ] Economia local.
- [ ] Agricultura.
- [ ] Principais localidades rurais.

Não publicar informações inventadas.

Sempre utilizar fontes confiáveis quando houver dados factuais.

---

# FASE 12 — CONCURSOS E PROCESSOS SELETIVOS

Criar uma estrutura específica para esse tipo de conteúdo.

Cada processo deve possuir:

- [ ] órgão;
- [ ] edital;
- [ ] cargos;
- [ ] vagas;
- [ ] salários;
- [ ] requisitos;
- [ ] período de inscrição;
- [ ] datas importantes;
- [ ] provas;
- [ ] resultados;
- [ ] convocações;
- [ ] documentos oficiais.

Adicionar link para o documento oficial.

Não simplesmente publicar o PDF sem contexto.

---

# FASE 13 — SERVIÇOS PÚBLICOS

Criar conteúdo útil para moradores.

Exemplos:

- [ ] Onde buscar atendimento de saúde.
- [ ] Telefones úteis.
- [ ] Escolas.
- [ ] UBS.
- [ ] Serviços municipais.
- [ ] Endereços públicos.
- [ ] Horários de atendimento, quando confirmados.
- [ ] Como acessar determinados serviços.

Todas as informações devem possuir fonte ou data de verificação quando necessário.

---

# FASE 14 — SEO ON-PAGE

Para cada página pública importante:

- [ ] title único;
- [ ] meta description única;
- [ ] URL amigável;
- [ ] canonical;
- [ ] H1 único;
- [ ] hierarquia H2/H3 correta;
- [ ] imagem otimizada;
- [ ] ALT descritivo;
- [ ] Open Graph;
- [ ] Twitter/X Card quando aplicável;
- [ ] dados estruturados adequados.

Não repetir a mesma meta description em dezenas de páginas.

---

# FASE 15 — DADOS ESTRUTURADOS

Para notícias, implementar corretamente `NewsArticle` ou `Article`, conforme aplicável.

Incluir somente dados reais:

- [ ] headline;
- [ ] image;
- [ ] datePublished;
- [ ] dateModified;
- [ ] author;
- [ ] publisher;
- [ ] logo.

Não inserir informações falsas para tentar melhorar rich results.

Validar o JSON-LD após implementação.

---

# FASE 16 — LINKS INTERNOS

Cada notícia deve apontar para conteúdos relacionados.

Exemplo:

Notícia sobre processo seletivo:

→ outras notícias do processo  
→ página do concurso  
→ categoria Concursos  
→ notícia relacionada  
→ documento oficial

Criar automaticamente seção:

**Leia também**

Mas somente mostrar conteúdos realmente relacionados.

Evitar links aleatórios.

---

# FASE 17 — SITEMAP

Auditar:

`/sitemap.xml`

Verificar:

- [ ] somente URLs válidas;
- [ ] URLs indexáveis;
- [ ] nenhuma página vazia;
- [ ] nenhuma categoria vazia;
- [ ] nenhum parâmetro desnecessário;
- [ ] canonical coerente;
- [ ] lastmod correto;
- [ ] sitemap funcionando sem erros.

---

# FASE 18 — ROBOTS.TXT

Auditar:

`/robots.txt`

Garantir:

- [ ] Googlebot não está bloqueado;
- [ ] páginas importantes não estão bloqueadas;
- [ ] sitemap informado;
- [ ] áreas administrativas protegidas;
- [ ] parâmetros desnecessários não indexados.

Não bloquear CSS, JavaScript ou imagens necessárias para renderização.

---

# FASE 19 — INDEXAÇÃO

Auditar todas as URLs.

Classificar:

### Indexar

- notícias;
- categorias com conteúdo;
- autores;
- páginas institucionais;
- conteúdos evergreen;
- guias;
- conteúdos úteis.

### Não indexar

- busca interna;
- filtros;
- paginações desnecessárias quando apropriado;
- páginas vazias;
- parâmetros;
- áreas administrativas;
- páginas sem valor para pesquisa.

Evitar `noindex` indiscriminadamente.

---

# FASE 20 — PÁGINAS INSTITUCIONAIS

Garantir que existam e funcionem:

- [ ] Sobre Nós
- [ ] Contato
- [ ] Política de Privacidade
- [ ] Termos de Uso
- [ ] Política Editorial
- [ ] Correções
- [ ] Autores

Todas devem ser acessíveis pelo rodapé.

---

# FASE 21 — CONTATO

Criar uma página de contato clara.

Deve possuir:

- [ ] formulário ou meio real de contato;
- [ ] e-mail oficial;
- [ ] finalidade do contato;
- [ ] contato para correções;
- [ ] contato comercial/publicidade, se existir.

Não criar e-mails fictícios.

---

# FASE 22 — PUBLICIDADE

Como o objetivo é AdSense:

- [ ] Não colocar anúncios antes da aprovação.
- [ ] Não criar espaços falsos de anúncios.
- [ ] Não usar scripts de redes desconhecidas.
- [ ] Não implementar mecanismos para gerar cliques.
- [ ] Não incentivar cliques.
- [ ] Não utilizar tráfego artificial.

Depois da aprovação, implementar anúncios de forma moderada.

---

# FASE 23 — UX

Testar o site em:

- [ ] Desktop
- [ ] Tablet
- [ ] Android
- [ ] iPhone

Verificar:

- [ ] menu;
- [ ] pesquisa;
- [ ] categorias;
- [ ] leitura;
- [ ] tamanho das fontes;
- [ ] espaçamento;
- [ ] contraste;
- [ ] imagens;
- [ ] velocidade;
- [ ] navegação entre matérias.

Eliminar:

- [ ] páginas vazias;
- [ ] componentes quebrados;
- [ ] botões sem função;
- [ ] links mortos;
- [ ] textos cortados;
- [ ] elementos sobrepostos.

---

# FASE 24 — PERFORMANCE

Executar auditoria de performance.

Verificar:

- [ ] tamanho das imagens;
- [ ] WebP/AVIF quando apropriado;
- [ ] lazy loading;
- [ ] CSS;
- [ ] JavaScript;
- [ ] fontes;
- [ ] cache;
- [ ] compressão;
- [ ] Core Web Vitals.

Não sacrificar acessibilidade ou funcionalidade somente para ganhar pontuação.

---

# FASE 25 — ACESSIBILIDADE

Verificar:

- [ ] ALT nas imagens;
- [ ] contraste;
- [ ] navegação por teclado;
- [ ] labels em formulários;
- [ ] botões identificáveis;
- [ ] headings corretos;
- [ ] links com nomes compreensíveis;
- [ ] conteúdo legível em celular.

---

# FASE 26 — CONTEÚDO DUPLICADO

Pesquisar:

- [ ] títulos duplicados;
- [ ] descrições duplicadas;
- [ ] notícias duplicadas;
- [ ] URLs duplicadas;
- [ ] conteúdo repetido;
- [ ] categorias duplicadas;
- [ ] páginas com parâmetros.

Quando duas URLs representam o mesmo conteúdo:

- [ ] escolher URL canônica;
- [ ] aplicar redirect quando apropriado.

---

# FASE 27 — NOTÍCIAS ANTIGAS

Não apagar notícias antigas simplesmente porque são antigas.

Classificar:

### Permanecer indexada
Conteúdo ainda útil.

### Atualizar
Conteúdo que pode ser mantido atualizado.

### Arquivar/noindex
Conteúdo extremamente curto ou sem valor atual.

Antes de remover ou aplicar `noindex`, registrar a decisão.

---

# FASE 28 — VERIFICAÇÃO DE CONTEÚDO SUPERFICIAL

Criar um relatório com todas as páginas que possuem:

- [ ] menos de 100 palavras;
- [ ] menos de 200 palavras;
- [ ] conteúdo repetitivo;
- [ ] pouca informação;
- [ ] somente comunicado;
- [ ] pouca utilidade para o usuário.

Não assumir que quantidade de palavras define qualidade.

Avaliar contexto e intenção da página.

---

# FASE 29 — SEGURANÇA

Verificar:

- [ ] HTTPS funcionando;
- [ ] HTTP redirecionando para HTTPS;
- [ ] www/non-www consistente;
- [ ] ausência de mixed content;
- [ ] formulários protegidos;
- [ ] headers de segurança quando apropriados;
- [ ] área administrativa não indexada.

---

# FASE 30 — GOOGLE SEARCH CONSOLE

Depois das correções:

- [ ] validar sitemap;
- [ ] verificar páginas indexadas;
- [ ] verificar páginas excluídas;
- [ ] verificar erros;
- [ ] verificar Core Web Vitals;
- [ ] verificar problemas de segurança;
- [ ] solicitar indexação das páginas principais modificadas.

Não solicitar indexação em massa desnecessariamente.

---

# FASE 31 — GOOGLE ADSENSE

Somente depois de todas as fases anteriores:

- [ ] verificar se todas as páginas institucionais estão acessíveis;
- [ ] verificar se o conteúdo principal está completo;
- [ ] verificar se não existem categorias vazias visíveis;
- [ ] verificar se não existem páginas quebradas;
- [ ] verificar se autores estão identificados;
- [ ] verificar se o site possui conteúdo original suficiente;
- [ ] verificar se o site possui navegação clara;
- [ ] verificar se não existem informações falsas;
- [ ] verificar política de privacidade;
- [ ] verificar política editorial;
- [ ] verificar contato;
- [ ] verificar HTTPS;
- [ ] verificar Search Console;
- [ ] somente então solicitar nova análise do AdSense.

---

# REGRA PRINCIPAL PARA O AGENTE

Não tentar "enganar" o Google.

Não:

- [ ] gerar centenas de textos automaticamente apenas para aumentar quantidade;
- [ ] criar palavras-chave artificialmente;
- [ ] criar páginas sem utilidade;
- [ ] inventar autores;
- [ ] inventar números;
- [ ] inventar fontes;
- [ ] copiar conteúdo de outros sites;
- [ ] criar notícias falsas;
- [ ] esconder conteúdo;
- [ ] criar categorias artificiais;
- [ ] usar técnicas de cloaking;
- [ ] gerar links artificiais;
- [ ] alterar informações reais apenas para SEO.

O objetivo é transformar o Busca Mais em um site genuinamente útil.

---

# CRITÉRIO DE CONCLUSÃO

O trabalho só deve ser considerado concluído quando:

- [ ] Não houver categorias vazias expostas.
- [ ] Não houver páginas importantes incompletas.
- [ ] As informações institucionais forem verdadeiras.
- [ ] Os autores estiverem identificados.
- [ ] As notícias possuírem estrutura editorial adequada.
- [ ] Houver conteúdo original suficiente.
- [ ] Houver conteúdos permanentes além das notícias.
- [ ] O sitemap estiver correto.
- [ ] O robots.txt estiver correto.
- [ ] Canonicals estiverem corretos.
- [ ] Dados estruturados estiverem válidos.
- [ ] Links internos estiverem funcionando.
- [ ] Não houver links quebrados relevantes.
- [ ] Site estiver responsivo.
- [ ] Site estiver em HTTPS.
- [ ] Performance estiver aceitável.
- [ ] Páginas institucionais estiverem acessíveis.
- [ ] Não houver informações falsas ou exageradas.
- [ ] Search Console estiver sem problemas críticos.

---

# RELATÓRIO FINAL OBRIGATÓRIO

Ao terminar, o agente deve entregar:

## 1. Problemas encontrados

Lista de todos os problemas encontrados.

## 2. Alterações realizadas

Lista exata dos arquivos, componentes, banco de dados e páginas alterados.

## 3. Alterações que NÃO foram feitas

Informar tudo que exigia decisão humana.

## 4. Conteúdos que precisam de revisão manual

Lista de matérias que ainda precisam de intervenção editorial.

## 5. URLs novas

Lista das páginas novas criadas.

## 6. URLs removidas/noindex

Lista e justificativa.

## 7. SEO

Informar:

- sitemap;
- robots;
- canonical;
- metadata;
- schema;
- indexação.

## 8. Performance

Informar problemas encontrados e melhorias realizadas.

## 9. AdSense

Responder objetivamente:

**"O Busca Mais está estruturalmente pronto para uma nova solicitação de avaliação do Google AdSense?"**

Responder:

- SIM
- NÃO

Se NÃO, listar exatamente o que ainda falta.

---

# IMPORTANTE

Antes de fazer qualquer alteração:

1. Fazer backup quando necessário.
2. Ler o código existente.
3. Entender a arquitetura.
4. Não reescrever funcionalidades que já funcionam.
5. Fazer alterações pequenas e verificáveis.
6. Testar após cada grupo de alterações.
7. Não apagar conteúdo sem registrar.
8. Não modificar credenciais ou arquivos `.env`.
9. Não alterar banco de produção sem confirmação quando houver risco de perda de dados.
10. Ao final, apresentar relatório completo.

O objetivo não é apenas conseguir aprovação no AdSense.

O objetivo é fazer o Busca Mais parecer e funcionar como um **portal regional confiável, útil, original e editorialmente consistente**.