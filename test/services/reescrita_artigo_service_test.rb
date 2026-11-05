require "test_helper"
require "minitest/mock"

class ReescritaArtigoServiceTest < ActiveSupport::TestCase
  setup do
    @autor = User.create!(
      nome: "Redação Teste",
      email: "redacao-reescrita-#{SecureRandom.hex(4)}@example.com",
      password: "senha12345",
      role: :administrador,
      ativo: true
    )
    @categoria = Category.create!(nome: "Categoria Reescrita #{SecureRandom.hex(3)}", ativo: true)
    @feed = FeedSource.create!(
      nome: "Mídia Extra",
      url: "https://midiaextra.com/feed/",
      category: @categoria,
      author: @autor,
      ativo: true,
      reescrita_automatica: true
    )

    @artigo = Article.create!(
      titulo: "Cadastro eleitoral é reaberto em todo o país",
      resumo: "Resumo original da matéria importada.",
      conteudo: "<p>Texto original que veio do feed e ainda não foi reescrito.</p>",
      status: :publicado,
      publicado_em: Time.current,
      category: @categoria,
      author: @autor,
      feed_source: @feed,
      fonte_nome: "Mídia Extra",
      fonte_url: "https://midiaextra.com/cadastro-eleitoral/",
      reescrita_status: nil
    )
    @slug_original = @artigo.slug
  end

  test "substitui o texto original pela versão da IA e preserva o slug" do
    resultado_ia = ReescritaEditorial::Resultado.new(
      sucesso: true,
      titulo: "Eleitores podem regularizar o título sem sair de casa",
      resumo: "Atendimento voltou a funcionar em todo o país.",
      conteudo: "<p>Novo texto completamente reescrito pela IA.</p><h2>Como fazer</h2><p>Use o canal digital.</p>",
      palavra_chave: "cadastro eleitoral",
      angulo: "prático",
      tags: [ "Eleições", "Serviços" ],
      modelo: "modelo-teste"
    )

    servico_fake = Object.new
    servico_fake.define_singleton_method(:chamar) { resultado_ia }

    resultado = ReescritaEditorial.stub(:new, servico_fake) do
      ReescritaArtigoService.new(@artigo).chamar
    end

    assert resultado.sucesso?, resultado.erro

    @artigo.reload
    assert_equal "Eleitores podem regularizar o título sem sair de casa", @artigo.titulo
    assert_equal "Atendimento voltou a funcionar em todo o país.", @artigo.resumo
    assert_includes @artigo.conteudo.to_plain_text, "Novo texto completamente reescrito"
    assert_equal "reescrito", @artigo.reescrita_status
    assert_equal "modelo-teste", @artigo.reescrita_modelo
    assert_equal "cadastro eleitoral", @artigo.palavra_chave_foco
    assert @artigo.mostrar_fonte?
    assert @artigo.publicado?
    assert_equal @slug_original, @artigo.slug
    assert_equal [ "Eleições", "Serviços" ].sort, @artigo.tags.map(&:nome).sort
  end

  test "não altera o conteúdo quando a IA falha e marca para revisão" do
    resultado_ia = ReescritaEditorial::Resultado.new(sucesso: false, erro: "Ollama indisponível")

    servico_fake = Object.new
    servico_fake.define_singleton_method(:chamar) { resultado_ia }

    resultado = ReescritaEditorial.stub(:new, servico_fake) do
      ReescritaArtigoService.new(@artigo).chamar
    end

    assert_not resultado.sucesso?
    assert_match(/Ollama indisponível/, resultado.erro)

    @artigo.reload
    assert_equal "Cadastro eleitoral é reaberto em todo o país", @artigo.titulo
    assert_includes @artigo.conteudo.to_plain_text, "Texto original que veio do feed"
    assert_equal "falhou", @artigo.reescrita_status
  end

  test "não rebaixa uma matéria já reescrita quando uma nova tentativa falha" do
    @artigo.update!(reescrita_status: "reescrito", reescrita_modelo: "modelo-antigo")

    resultado_ia = ReescritaEditorial::Resultado.new(sucesso: false, erro: "timeout")

    servico_fake = Object.new
    servico_fake.define_singleton_method(:chamar) { resultado_ia }

    ReescritaEditorial.stub(:new, servico_fake) do
      ReescritaArtigoService.new(@artigo).chamar
    end

    @artigo.reload
    assert_equal "reescrito", @artigo.reescrita_status
    assert_equal "modelo-antigo", @artigo.reescrita_modelo
  end

  test "recusa artigo que não veio de um feed" do
    @artigo.update!(feed_source: nil)

    resultado = ReescritaArtigoService.new(@artigo).chamar

    assert_not resultado.sucesso?
    assert_match(/não foi importado de um feed/i, resultado.erro)
  end
end
