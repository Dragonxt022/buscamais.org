# Gera uma matéria completa (rascunho) a partir de assunto + ângulo definidos
# pelo editor, usando o modelo configurado em OllamaClient. Não inventa fatos
# específicos — o prompt instrui o modelo a evitar números/datas/nomes que não
# tenha certeza, mantendo o padrão editorial do site (ver política editorial).
class GeradorMateriaIa
  Resultado = Struct.new(:sucesso, :artigo, :erro, keyword_init: true) do
    alias_method :sucesso?, :sucesso
  end

  TAMANHOS = {
    "curto"  => "600 a 900 palavras",
    "medio"  => "1000 a 1600 palavras",
    "longo"  => "1800 a 2800 palavras"
  }.freeze

  def initialize(autor:, categoria:, assunto:, categorias_extra: [], rumo: nil,
                 tags_sugeridas: nil, palavra_chave_foco: nil, tamanho: "medio", dados_referencia: nil)
    @autor              = autor
    @categoria          = categoria
    @categorias_extra   = categorias_extra
    @assunto            = assunto
    @rumo               = rumo
    @tags_sugeridas     = tags_sugeridas
    @palavra_chave_foco = palavra_chave_foco
    @tamanho            = TAMANHOS.key?(tamanho) ? tamanho : "medio"
    @dados_referencia   = dados_referencia
  end

  def chamar
    dados  = OllamaClient.generate_json(prompt: montar_prompt)
    artigo = criar_rascunho(dados)
    Resultado.new(sucesso: true, artigo: artigo, erro: nil)
  rescue OllamaClient::Erro => e
    Rails.logger.error("[GeradorMateriaIa] #{e.message}")
    Resultado.new(sucesso: false, artigo: nil, erro: e.message)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("[GeradorMateriaIa] artigo inválido: #{e.message}")
    Resultado.new(sucesso: false, artigo: nil, erro: "A matéria gerada não passou nas validações: #{e.message}")
  end

  private

  def dados_referencia_bloco
    return "" unless @dados_referencia.present?

    <<~BLOCO

      Dados de referência (informação real fornecida pelo editor — cole aqui trechos de comunicados oficiais, anotações de apuração, ou qualquer fato verificado):
      """
      #{@dados_referencia}
      """
    BLOCO
  end

  def montar_prompt
    <<~PROMPT
      Você é um editor experiente do Busca Mais, um jornal independente e descentralizado que cobre Cujubim, Rio Crespo e a região do Vale do Jamari, em Rondônia. Seu trabalho é escrever matérias com riqueza de detalhes e informações que realmente ajudam e mudam a vida de quem lê — não é para reproduzir comunicados oficiais, é para contextualizar, explicar o "porquê" das coisas e o que cada informação significa na prática para o leitor.

      Escreva uma matéria jornalística completa sobre o seguinte:

      Assunto: #{@assunto}
      #{"Ângulo/enfoque desejado: #{@rumo}" if @rumo.present?}
      Categoria principal: #{@categoria.nome}
      #{"Categorias relacionadas: #{@categorias_extra.map(&:nome).join(', ')}" if @categorias_extra.any?}
      #{"Palavra-chave de foco (use naturalmente no título, no início do texto e mais algumas vezes ao longo do conteúdo, sem forçar): #{@palavra_chave_foco}" if @palavra_chave_foco.present?}
      #{"Sugestões de tags do editor (use se fizerem sentido, pode completar com outras): #{@tags_sugeridas}" if @tags_sugeridas.present?}
      #{dados_referencia_bloco}

      Regras importantes:
      #{@dados_referencia.present? ? '- Use os "Dados de referência" acima como a ÚNICA fonte de fatos específicos (datas, números, nomes, valores, declarações). Você pode reorganizar, explicar e contextualizar esses dados livremente, mas não pode adicionar nenhum fato específico que não esteja neles.' : '- NÃO invente fatos específicos — números, datas, nomes de pessoas, valores em R$, declarações entre aspas — que você não tenha certeza de que sejam reais. Quando precisar de um dado assim e não tiver certeza, escreva de forma genérica em vez de inventar (ex.: "nos últimos anos" em vez de um ano específico inventado).'}
      - NÃO copie texto literalmente de nenhuma fonte; reescreva com suas próprias palavras, mesmo quando usar os dados de referência.
      - Tom: analítico, claro e direto, como um bom texto jornalístico brasileiro de profundidade — não um comunicado oficial reescrito. Pode usar <strong> para destacar fatos-chave e <em> para ênfase pontual, com moderação.
      - Tamanho alvo do campo "conteudo_html": #{TAMANHOS.fetch(@tamanho)}.
      - Estrutura do campo "conteudo_html": parágrafos curtos (2 a 4 frases cada), como jornalismo real — nunca blocos gigantes de texto. Use <h2> para separar seções quando o texto for mais longo.
      - O campo "conteudo_html" deve ser HTML simples e válido, usando apenas as tags <p>, <strong>, <em>, <h2>, <h3>, <ul>, <li>, <blockquote>. Não inclua <html>, <head>, <body>, nem markdown.
      - O campo "resumo" deve ter entre 120 e 156 caracteres — um resumo que funcione como chamada da matéria, não uma frase genérica.
      - O campo "titulo" deve ter entre 40 e 60 caracteres, ser específico e informativo, sem sensacionalismo.
      - O campo "tags" deve ser uma lista de 3 a 6 tags curtas e relevantes, em português, com a primeira letra maiúscula.

      Responda SOMENTE com um JSON válido neste formato exato, sem nenhum texto antes ou depois, sem markdown, sem crases:
      {"titulo": "...", "resumo": "...", "conteudo_html": "...", "tags": ["...", "..."]}
    PROMPT
  end

  def criar_rascunho(dados)
    artigo = Article.new(
      titulo:              dados["titulo"].to_s.strip.presence || @assunto.to_s.truncate(180),
      resumo:              dados["resumo"].to_s.strip.presence,
      status:              :rascunho,
      category:            @categoria,
      author:              @autor,
      palavra_chave_foco:  @palavra_chave_foco.presence
    )
    artigo.conteudo = dados["conteudo_html"].to_s
    artigo.save!

    artigo.categorias_extra_ids = @categorias_extra.map(&:id) if @categorias_extra.any?

    nomes_tags = Array(dados["tags"]).map { |t| t.to_s.strip }.reject(&:blank?).uniq
    artigo.tags = nomes_tags.map { |nome| Tag.find_or_create_by!(nome: nome) } if nomes_tags.any?

    artigo
  end
end
