require "test_helper"
require "minitest/mock"

class ReescritaArtigosJobTest < ActiveJob::TestCase
  setup do
    @autor = User.create!(
      nome: "Redação Lote",
      email: "redacao-lote-#{SecureRandom.hex(4)}@example.com",
      password: "senha12345",
      role: :administrador,
      ativo: true
    )
    @categoria = Category.create!(nome: "Categoria Lote #{SecureRandom.hex(3)}", ativo: true)
    @feed = FeedSource.create!(
      nome: "Feed Lote",
      url: "https://lote.example.com/feed/",
      category: @categoria,
      author: @autor,
      reescrita_automatica: true
    )
    @outro_feed = FeedSource.create!(
      nome: "Outro Feed Lote",
      url: "https://outro-lote.example.com/feed/",
      category: @categoria,
      author: @autor,
      reescrita_automatica: true
    )

    @pendente  = criar_artigo("Pendente", @feed)
    @falhou    = criar_artigo("Falhou", @feed, reescrita_status: "falhou", publicado_em: 1.hour.ago)
    @reescrito = criar_artigo("Já reescrito", @feed, reescrita_status: "reescrito")
    @arquivado = criar_artigo("Arquivado", @feed, status: :arquivado)
    @sem_fonte = criar_artigo("Sem fonte", @feed, fonte_url: nil)
    @outro     = criar_artigo("Outro feed", @outro_feed)
  end

  test "processa só matérias pendentes do feed escolhido" do
    chamados = []

    fabrica = lambda do |artigo|
      servico = Object.new
      servico.define_singleton_method(:chamar) do
        chamados << artigo.id
        ReescritaArtigoService::Resultado.new(sucesso: true, artigo: artigo)
      end
      servico
    end

    ReescritaArtigoService.stub(:new, fabrica) do
      ReescritaArtigosJob.new.perform(feed_id: @feed.id, limite: 10)
    end

    assert_equal 2, chamados.size
    assert_includes chamados, @pendente.id
    assert_includes chamados, @falhou.id
    assert_not_includes chamados, @reescrito.id
    assert_not_includes chamados, @arquivado.id
    assert_not_includes chamados, @sem_fonte.id
    assert_not_includes chamados, @outro.id
    assert_equal @pendente.id, chamados.first, "matérias nunca processadas devem ter prioridade"
  end

  private

  def criar_artigo(titulo, feed, reescrita_status: nil, status: :publicado, publicado_em: Time.current,
                   fonte_url: "https://exemplo.com/#{SecureRandom.hex(4)}")
    Article.create!(
      titulo: "#{titulo} #{SecureRandom.hex(3)}",
      resumo: "Resumo de teste.",
      conteudo: "<p>Conteúdo original de teste.</p>",
      status: status,
      publicado_em: publicado_em,
      category: @categoria,
      author: @autor,
      feed_source: feed,
      fonte_nome: feed.nome,
      fonte_url: fonte_url,
      reescrita_status: reescrita_status
    )
  end
end
