---
name: reescrita-editorial
description: Reescreve matérias capturadas via RSS transformando o conteúdo em um novo artigo original, com ângulo próprio, sem plágio e otimizado para SEO. Use quando o usuário colar o conteúdo de uma matéria e pedir para "reescrever", "readaptar", "dar outro ângulo" ou "transformar em artigo original".
---

# Skill: Reescrita Editorial Segura

## Objetivo
Transformar matérias capturadas via RSS em conteúdo **original**, com **ângulo editorial próprio**, mantendo a veracidade dos fatos, sem caracterizar plágio e sem penalização por SEO (Google).

## Quando usar
Quando o usuário colar o texto de uma matéria e solicitar:
- "Reescreva"
- "Readapte"
- "Dê outro ângulo"
- "Transforme em artigo original"
- "Deixe sem plágio"

## Regras obrigatórias (não negociáveis)

### ✅ FAZER
1. **Reescrever do zero**, nunca parafrasear frase por frase.
2. **Mudar a estrutura narrativa**: se o original começa pelo fato, comece pelo contexto; se começa pelo contexto, comece pelo impacto.
3. **Adotar um ângulo próprio** (ver seção "Ângulos").
4. **Adicionar análise, contexto ou conexão** que o original não tem (sem inventar fatos).
5. **Reformular 100% das frases** — nenhuma frase pode manter mais de 5-6 palavras idênticas consecutivas do original.
6. **Citar a fonte original** com link (isso protege juridicamente e o Google valoriza).
7. **Variar vocabulário**: sinônimos, reformulações, mudança de voz (ativa↔passiva).
8. **Reordenar informações** conforme o novo ângulo.
9. **Manter dados factuais intactos**: números, nomes, datas, cargos, citações diretas entre aspas.

### ❌ NÃO FAZER
1. Não copiar trechos literais (exceto citações diretas, com aspas e atribuição).
2. Não inventar fatos, números ou declarações.
3. Não usar "spin" automático (trocar palavras por sinônimos ruins).
4. Não manter a mesma ordem de parágrafos do original.
5. Não usar o mesmo título (criar novo).
6. Não omitir a fonte.
7. Não gerar conteúdo genérico/"enchimento".

## Ângulos possíveis (escolher 1, ou perguntar ao usuário)
- **Contextual**: situa o fato em um cenário maior
- **Analítico**: explica o "porquê" e as implicações
- **Prático**: o que isso significa para o leitor (consequências, dicas)
- **Contra-intuitivo**: destaca o que ninguém está falando
- **Histórico**: conecta com antecedentes
- **Comparativo**: relaciona com casos semelhantes
- **Local/regional**: adapta o impacto para o público do site

Se o usuário não especificar, escolha o mais adequado e **avise qual escolheu**.

## Estrutura do novo artigo

1. **Título novo** (não pode repetir o original; usar palavras-chave naturalmente)
2. **Linha fina / subtítulo** (1 frase que resume o ângulo)
3. **Lead** (2-3 frases: o quê + por que importa agora)
4. **Corpo** (3-5 blocos, cada um com subtítulo H2 quando fizer sentido)
5. **Fecho** (conclusão, implicação ou provocação)
6. **Fonte** (link + nome do veículo original)
7. **Meta description** (até 155 caracteres)
8. **3-5 palavras-chave sugeridas**
9. **Sugestão de slug** para URL

## SEO — checklist
- [ ] Título entre 50-60 caracteres, com palavra-chave
- [ ] H1 = título; H2s com variações da palavra-chave
- [ ] Primeiro parágrafo contém a palavra-chave principal
- [ ] Meta description única (não copiada do original)
- [ ] Parágrafos curtos (2-4 linhas)
- [ ] Sem keyword stuffing
- [ ] Link para fonte original (E-E-A-T)
- [ ] Linguagem natural, sem frases robóticas

## Processo (passo a passo ao receber a matéria)
1. Ler e **extrair os fatos-chave** (quem, o quê, quando, onde, por quê, como).
2. Perguntar (ou decidir) o **ângulo**.
3. **Descartar a redação original** — trabalhar apenas com os fatos.
4. Escrever o novo artigo seguindo a estrutura acima.
5. Revisar: alguma frase ficou parecida demais? Se sim, reescrever.
6. Entregar com o bloco "Fonte + SEO" no final.

## Formato de saída obrigatório

### No modo automático (RSS → Ollama)
A resposta deve ser **somente** um objeto JSON válido, sem markdown e sem cercas de código:

```json
{
  "titulo": "novo título, 50–60 caracteres",
  "resumo": "linha fina / meta description, até 155 caracteres",
  "angulo": "ângulo escolhido em uma frase curta",
  "palavra_chave": "palavra-chave principal",
  "tags": ["3 a 5 tags curtas"],
  "conteudo_html": "<p>lead…</p><h2>…</h2><p>…</p>"
}
```

Regras do HTML: usar apenas `<p>`, `<h2>`, `<h3>`, `<ul>`, `<ol>`, `<li>`,
`<strong>`, `<em>`, `<blockquote>` e `<a href="…">`. Não usar `<h1>`, `<img>`,
`<script>`, `<div>` nem markdown. Não incluir rodapé, assinatura ou “Fonte:” no
conteúdo — o site acrescenta o crédito da fonte automaticamente.

### No modo manual (editor)
Entregar o artigo em markdown seguido do bloco **Fonte + SEO**:

```
Fonte: [nome do veículo](URL original)
Meta description: …
Palavras-chave: …
Slug sugerido: …
```

## Automação no Busca Mais

O pipeline `FeedSyncService` usa esta skill automaticamente quando o feed tem
**Reescrever com IA (Ollama)** marcado:

1. O texto do RSS é limpo (scripts, imagens, créditos da origem).
2. A IA recebe apenas os fatos e devolve o JSON acima.
3. O sistema valida título, tamanho e **similaridade com o original** (5-gramas).
4. Se a reescrita passar, a matéria segue a opção de publicação do feed.
5. Se a IA falhar, gerar texto curto ou parecido demais com o original, a
   matéria entra como **aguardando revisão** — nunca publica o texto copiado.
