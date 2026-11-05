require "net/http"
require "uri"
require "json"

# Cliente mínimo da API local do Ollama (POST /api/chat).
#
# A configuração vem do painel (Admin → Configurações → Reescrita com IA) e
# pode ser sobrescrita por variáveis de ambiente:
#
#   OLLAMA_URL     (padrão: http://localhost:11434)
#   OLLAMA_MODEL   (ex.: llama3.1:8b, qwen2.5:7b)
#   OLLAMA_TIMEOUT (segundos de leitura, padrão: 300)
#   OLLAMA_NUM_CTX (tamanho da janela de contexto, padrão: 8192)
#   OLLAMA_NUM_PREDICT (máximo de tokens gerados, padrão: 1500)
class OllamaClient
  class Erro < StandardError; end

  URL_PADRAO         = "http://localhost:11434".freeze
  TIMEOUT_PADRAO     = 300
  NUM_CTX_PADRAO     = 8192
  NUM_PREDICT_PADRAO = 1500

  attr_reader :modelo

  def initialize(url: nil, modelo: nil, timeout: nil)
    @url         = normalizar_url(url.presence || SiteSetting["ollama_url"].presence ||
                                  ENV["OLLAMA_URL"].presence || ENV["OLLAMA_HOST"].presence || URL_PADRAO)
    @modelo      = (modelo.presence || SiteSetting["ollama_model"].presence || ENV["OLLAMA_MODEL"].presence).to_s.strip
    @timeout     = (timeout.presence || ENV["OLLAMA_TIMEOUT"].presence || TIMEOUT_PADRAO).to_i.clamp(30, 900)
    @num_ctx     = (ENV["OLLAMA_NUM_CTX"].presence || NUM_CTX_PADRAO).to_i.clamp(2048, 32768)
    @num_predict = (ENV["OLLAMA_NUM_PREDICT"].presence || NUM_PREDICT_PADRAO).to_i.clamp(256, 4096)
  end

  def configurado?
    @modelo.present?
  end

  # Envia a conversa e devolve o texto bruto da resposta do assistente.
  # `formato: "json"` faz o Ollama restringir a saída a um JSON válido.
  def conversar(mensagens, formato: "json", temperatura: 0.65)
    raise Erro, "Nenhum modelo do Ollama foi configurado" unless configurado?

    corpo = {
      model: @modelo,
      messages: mensagens,
      stream: false,
      format: formato,
      keep_alive: "10m",
      options: {
        temperature: temperatura,
        num_ctx: @num_ctx,
        num_predict: @num_predict
      }
    }.to_json

    resposta = post("/api/chat", corpo)
    dados    = JSON.parse(resposta)
    raise Erro, "O Ollama devolveu uma resposta inesperada" unless dados.is_a?(Hash)

    raise Erro, "O Ollama respondeu com erro: #{dados['error']}" if dados["error"].present?

    conteudo = dados.dig("message", "content").to_s
    raise Erro, "O Ollama devolveu uma resposta vazia" if conteudo.strip.blank?

    conteudo
  rescue JSON::ParserError
    raise Erro, "O Ollama devolveu uma resposta que não é JSON"
  end

  private

  def post(caminho, corpo)
    uri = URI.join(@url, caminho)

    resposta = Net::HTTP.start(
      uri.host, uri.port,
      use_ssl: uri.scheme == "https",
      open_timeout: 10,
      read_timeout: @timeout
    ) do |http|
      requisicao = Net::HTTP::Post.new(uri.request_uri)
      requisicao["Content-Type"] = "application/json"
      requisicao["Accept"] = "application/json"
      requisicao.body = corpo
      http.request(requisicao)
    end

    unless resposta.is_a?(Net::HTTPSuccess)
      detalhe = resposta.body.to_s.squish.truncate(300)
      raise Erro, "O Ollama respondeu HTTP #{resposta.code}: #{detalhe}"
    end

    resposta.body.to_s
  rescue Errno::ECONNREFUSED
    raise Erro, "Não foi possível conectar ao Ollama em #{@url}. Ele está rodando?"
  rescue Net::OpenTimeout, Net::ReadTimeout
    raise Erro, "O Ollama demorou mais de #{@timeout}s para responder"
  rescue SocketError, SystemCallError => e
    raise Erro, "Falha de rede ao acessar o Ollama: #{e.message}"
  end

  def normalizar_url(url)
    url = url.to_s.strip
    url = "http://#{url}" unless url.match?(%r{\Ahttps?://}i)
    url.chomp("/")
  end
end
