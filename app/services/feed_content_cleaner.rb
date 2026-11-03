# Remove do conteúdo importado os créditos/assinaturas do site de origem,
# como "<p><em>Da Redação Mídia Extra</em></p>" ou "Fonte: ...".
#
# A remoção é conservadora: só apaga nós de texto curtos que começam com
# padrões de crédito (ou que são exatamente o nome da fonte), e depois limpa
# parágrafos que ficaram vazios.
class FeedContentCleaner
  LIMITE_TEXTO_CREDITO = 160

  PADROES = [
    /\A\s*(da\s+)?redação\b/i,
    /\A\s*(fonte|crédito|credito)\s*:/i,
    /\A\s*com\s+(informações|informacoes|agências|agencias)\b/i
  ].freeze

  def initialize(nomes = [])
    @nomes = Array(nomes).compact.map { |nome| nome.to_s.strip }.reject(&:blank?).uniq
  end

  def remover_creditos(fragmento)
    fragmento.xpath(".//text()").each do |no|
      texto = no.text.to_s.squish
      next if texto.blank? || texto.length > LIMITE_TEXTO_CREDITO
      next unless credito?(texto)

      pai = no.parent
      if pai.text.to_s.squish == texto
        pai.remove
      else
        no.remove
      end
    end

    fragmento.css("p, em, strong, small, footer").each do |bloco|
      bloco.remove if bloco.text.to_s.squish.blank? && bloco.css("img").empty?
    end

    fragmento
  end

  private

  def credito?(texto)
    return true if PADROES.any? { |padrao| texto.match?(padrao) }

    @nomes.any? do |nome|
      texto.match?(/\A\s*#{Regexp.escape(nome)}\s*\z/i)
    end
  end
end
