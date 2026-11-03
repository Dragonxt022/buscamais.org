require "test_helper"

class FeedContentCleanerTest < ActiveSupport::TestCase
  def limpar(html, nomes = [ "Mídia Extra" ])
    fragmento = Nokogiri::HTML.fragment(html)
    FeedContentCleaner.new(nomes).remover_creditos(fragmento).to_html
  end

  test "remove assinatura da redação da origem" do
    limpo = limpar("<p>Texto da matéria.</p><p><em>Da Redação Mídia Extra</em></p>")

    assert_includes limpo, "Texto da matéria."
    assert_not_includes limpo, "Da Redação"
    assert_not_includes limpo, "Mídia Extra"
  end

  test "remove linha de fonte e deixa o restante intacto" do
    limpo = limpar("<p>Por isso, o prazo é curto.</p><p>Fonte: Mídia Extra</p>")

    assert_includes limpo, "Por isso, o prazo é curto."
    assert_not_includes limpo, "Fonte:"
  end

  test "não remove o nome da fonte quando faz parte de uma frase normal" do
    html = "<p>A Mídia Extra informou que o prazo termina hoje.</p>"
    assert_includes limpar(html), "A Mídia Extra informou que o prazo termina hoje."
  end
end
