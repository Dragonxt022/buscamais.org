require "test_helper"

class FeedSourceTest < ActiveSupport::TestCase
  test "exige uma URL http(s) válida" do
    feed = FeedSource.new(nome: "Teste", url: "ftp://exemplo.com/feed")
    assert_not feed.valid?
    assert_includes feed.errors[:url], "deve ser um endereço http(s) válido"
  end

  test "considera vencido quando nunca sincronizou" do
    feed = FeedSource.new(nome: "Teste", url: "https://exemplo.com/feed", intervalo_minutos: 60, ativo: true)
    assert feed.devido?
  end

  test "respeita o intervalo configurado" do
    feed = FeedSource.new(nome: "Teste", url: "https://exemplo.com/feed", intervalo_minutos: 60, ativo: true)

    feed.ultima_sincronizacao_em = 30.minutes.ago
    assert_not feed.devido?

    feed.ultima_sincronizacao_em = 61.minutes.ago
    assert feed.devido?
  end

  test "feed pausado nunca está vencido" do
    feed = FeedSource.new(nome: "Teste", url: "https://exemplo.com/feed", ativo: false)
    assert_not feed.devido?
  end
end
