require "test_helper"
require "minitest/mock"

class ReescritaEditorialTest < ActiveSupport::TestCase
  class ClienteFalso
    attr_reader :modelo

    def initialize(resposta, modelo: "modelo-teste")
      @resposta = resposta
      @modelo   = modelo
    end

    def configurado?
      true
    end

    def conversar(_mensagens, **_opcoes)
      @resposta
    end
  end

  ORIGINAL = <<~HTML.freeze
    <p>A Justiça Eleitoral reabriu nesta terça-feira (3) o cadastro eleitoral em todo o país.
    Os serviços podem ser solicitados pelo Autoatendimento Eleitoral.
    O atendimento presencial também está disponível nos cartórios.
    O prazo para regularizar a situação vai até o dia 5 de maio, segundo o calendário
    divulgado pelo Tribunal Superior Eleitoral.</p>
  HTML

  REESCRITO = <<~HTML.freeze
    <p>Depois de um período de manutenção, eleitores brasileiros podem voltar a resolver
    pendências com a Justiça Eleitoral. Quem precisa tirar o primeiro título, transferir o
    domicílio ou corrigir dados já encontra o serviço funcionando.</p>
    <h2>O que separar antes de ir ao cartório</h2>
    <p>A recomendação é reunir documentos antes de iniciar o procedimento. Nos cartórios,
    o atendimento segue mediante agendamento. Para quem prefere evitar filas, a opção
    digital continua disponível e permite concluir etapas pelo celular.</p>
  HTML

  test "aceita uma reescrita realmente diferente do original" do
    servico = ReescritaEditorial.new(
      titulo: "Cadastro eleitoral é reaberto e serviços voltam em todo o país",
      conteudo: ORIGINAL,
      fonte_nome: "Mídia Extra",
      fonte_url: "https://midiaextra.com/materia/",
      cliente: ClienteFalso.new(resposta_json(REESCRITO))
    )

    resultado = ReescritaEditorial.stub(:ativa?, true) { servico.chamar }

    assert resultado.sucesso?, resultado.erro
    assert_equal "Justiça Eleitoral retoma atendimento e libera serviços digitais", resultado.titulo
    assert_equal "modelo-teste", resultado.modelo
    assert_includes resultado.conteudo, "<h2>"
    assert_equal [ "Eleições", "Serviços" ], resultado.tags
    assert_equal "cadastro eleitoral", resultado.palavra_chave
  end

  test "recusa texto praticamente igual ao original" do
    servico = ReescritaEditorial.new(
      titulo: "Cadastro eleitoral é reaberto e serviços voltam em todo o país",
      conteudo: ORIGINAL,
      fonte_nome: "Mídia Extra",
      cliente: ClienteFalso.new(resposta_json(ORIGINAL, titulo: "Outro título completamente diferente"))
    )

    resultado = ReescritaEditorial.stub(:ativa?, true) { servico.chamar }

    assert_not resultado.sucesso?
    assert_match(/parecido demais/i, resultado.erro)
  end

  test "recusa título igual ao original" do
    titulo = "Cadastro eleitoral é reaberto e serviços voltam em todo o país"
    servico = ReescritaEditorial.new(
      titulo: titulo,
      conteudo: ORIGINAL,
      fonte_nome: "Mídia Extra",
      cliente: ClienteFalso.new(resposta_json(REESCRITO, titulo: titulo))
    )

    resultado = ReescritaEditorial.stub(:ativa?, true) { servico.chamar }

    assert_not resultado.sucesso?
    assert_match(/praticamente igual/i, resultado.erro)
  end

  test "extrai JSON mesmo quando o modelo devolve cerca de código" do
    resposta = "```json\n#{resposta_json(REESCRITO)}\n```"
    servico = ReescritaEditorial.new(
      titulo: "Cadastro eleitoral é reaberto e serviços voltam em todo o país",
      conteudo: ORIGINAL,
      fonte_nome: "Mídia Extra",
      cliente: ClienteFalso.new(resposta)
    )

    resultado = ReescritaEditorial.stub(:ativa?, true) { servico.chamar }

    assert resultado.sucesso?, resultado.erro
  end

  test "remove scripts e tags perigosas do HTML gerado pela IA" do
    html = REESCRITO + "<script>alert('xss')</script><img src='https://exemplo.com/foto.jpg'>"
    servico = ReescritaEditorial.new(
      titulo: "Cadastro eleitoral é reaberto e serviços voltam em todo o país",
      conteudo: ORIGINAL,
      fonte_nome: "Mídia Extra",
      cliente: ClienteFalso.new(resposta_json(html))
    )

    resultado = ReescritaEditorial.stub(:ativa?, true) { servico.chamar }

    assert resultado.sucesso?, resultado.erro
    assert_not_includes resultado.conteudo, "script"
    assert_not_includes resultado.conteudo, "<img"
  end

  test "devolve erro quando o modelo não está configurado" do
    cliente = ClienteFalso.new("{}")
    def cliente.configurado?
      false
    end

    servico = ReescritaEditorial.new(
      titulo: "Cadastro eleitoral é reaberto e serviços voltam em todo o país",
      conteudo: ORIGINAL,
      fonte_nome: "Mídia Extra",
      cliente: cliente
    )

    resultado = ReescritaEditorial.stub(:ativa?, true) { servico.chamar }

    assert_not resultado.sucesso?
    assert_match(/não foi configurado/i, resultado.erro)
  end

  private

  def resposta_json(conteudo, titulo: "Justiça Eleitoral retoma atendimento e libera serviços digitais")
    {
      titulo: titulo,
      resumo: "Atendimento foi retomado em todo o país e pode ser feito à distância.",
      angulo: "prático",
      palavra_chave: "cadastro eleitoral",
      tags: [ "Eleições", "Serviços" ],
      conteudo_html: conteudo
    }.to_json
  end
end
