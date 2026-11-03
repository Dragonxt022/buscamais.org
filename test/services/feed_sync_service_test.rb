require "test_helper"

class FeedSyncServiceTest < ActiveSupport::TestCase
  setup do
    @autor = User.create!(
      nome: "Redação Teste",
      email: "redacao-feed-#{SecureRandom.hex(4)}@example.com",
      password: "senha12345",
      role: :administrador,
      ativo: true
    )
    @categoria = Category.create!(nome: "Categoria Feed Teste", ativo: true)
    @politica  = Category.create!(nome: "Política", ativo: true)

    @feed = FeedSource.create!(
      nome: "Mídia Extra",
      url: "https://midiaextra.com/feed/",
      category: @categoria,
      author: @autor,
      ativo: true,
      publicar_automaticamente: true,
      importar_imagem: false,
      limite_por_sincronizacao: 10
    )
    @xml = file_fixture("feed_rss.xml").read
  end

  test "importa os itens como matérias publicadas" do
    resultado = FeedSyncService.new(@feed, xml: @xml).chamar

    assert resultado.sucesso?
    assert_equal 3, resultado.importados

    artigo = Article.find_by!(fonte_url: "https://midiaextra.com/cadastro-eleitoral-reaberto-servicos-eleitor/")
    assert artigo.publicado?
    assert_equal @feed, artigo.feed_source
    assert_equal @autor, artigo.author
    assert_equal @politica, artigo.category
    assert_equal Time.utc(2026, 11, 3, 16, 0, 26), artigo.publicado_em
    assert_includes artigo.conteudo.to_plain_text, "A Justiça Eleitoral reabriu"
    assert_includes artigo.resumo, "Justiça Eleitoral retoma"
    assert_equal 3, @feed.reload.total_importados
  end

  test "remove scripts e imagens do corpo da matéria" do
    FeedSyncService.new(@feed, xml: @xml).chamar

    artigo = Article.find_by!(fonte_url: "https://midiaextra.com/policia-investiga-queda-asa-delta-sao/")
    html = artigo.conteudo.body.to_html

    assert_not_includes html, "script"
    assert_not_includes html, "<img"
    assert_not_includes artigo.conteudo.to_plain_text, "alert("
    assert_includes html, "A Polícia Civil do Rio investiga"
    assert_not_includes artigo.conteudo.to_plain_text, "Da Redação"
  end

  test "converte links relativos do feed em links absolutos" do
    FeedSyncService.new(@feed, xml: @xml).chamar

    artigo = Article.find_by!(fonte_url: "https://midiaextra.com/cadastro-eleitoral-reaberto-servicos-eleitor/")
    assert_includes artigo.conteudo.body.to_html, "https://midiaextra.com/outra-noticia/"
  end

  test "não duplica matérias em sincronizações seguintes" do
    FeedSyncService.new(@feed, xml: @xml).chamar
    resultado = FeedSyncService.new(@feed, xml: @xml).chamar

    assert resultado.sucesso?
    assert_equal 0, resultado.importados
    assert_equal 3, resultado.ignorados
    assert_equal 3, @feed.articles.count
  end

  test "respeita o limite por sincronização e importa as mais recentes primeiro" do
    @feed.update!(limite_por_sincronizacao: 1)

    resultado = FeedSyncService.new(@feed, xml: @xml).chamar

    assert_equal 1, resultado.importados
    assert Article.exists?(external_id: "https://midiaextra.com/cadastro-eleitoral-reaberto-servicos-eleitor/")
    assert_not Article.exists?(external_id: "https://midiaextra.com/inscricoes-fies-vagas-remanescentes-terca/")
  end

  test "quando não publica automaticamente, envia para revisão" do
    @feed.update!(publicar_automaticamente: false)

    FeedSyncService.new(@feed, xml: @xml).chamar

    artigo = Article.find_by!(fonte_url: "https://midiaextra.com/cadastro-eleitoral-reaberto-servicos-eleitor/")
    assert artigo.aguardando_revisao?
  end

  test "usa a categoria padrão quando nenhuma categoria do feed existe no site" do
    @politica.destroy!

    FeedSyncService.new(@feed, xml: @xml).chamar

    artigo = Article.find_by!(fonte_url: "https://midiaextra.com/cadastro-eleitoral-reaberto-servicos-eleitor/")
    assert_equal @categoria, artigo.category
  end

  test "registra falha quando o endereço não devolve um feed" do
    resultado = FeedSyncService.new(@feed, xml: "<html><body>não é um feed</body></html>").chamar

    assert_not resultado.sucesso?
    assert_equal "erro", @feed.reload.ultimo_status
  end
end
