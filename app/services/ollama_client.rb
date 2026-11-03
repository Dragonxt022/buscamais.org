# Cliente simples para o Ollama local (que expõe o modelo cloud configurado
# via `ollama pull <modelo>-cloud` através da mesma API local de sempre).
class OllamaClient
  class Erro < StandardError; end

  BASE_URL = ENV.fetch("OLLAMA_URL", "http://localhost:11434")
  MODEL    = ENV.fetch("OLLAMA_MODEL", "gemma4:31b-cloud")

  # Chama o modelo pedindo saída em JSON e devolve o Hash já parseado.
  def self.generate_json(prompt:, timeout: 300)
    uri  = URI("#{BASE_URL}/api/generate")
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = timeout
    http.open_timeout = 10

    req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    req.body = {
      model:  MODEL,
      prompt: prompt,
      format: "json",
      stream: false
    }.to_json

    res = http.request(req)
    raise Erro, "Ollama respondeu #{res.code}: #{res.body.to_s.truncate(300)}" unless res.is_a?(Net::HTTPSuccess)

    envelope = JSON.parse(res.body)
    raise Erro, "Resposta do Ollama sem campo 'response'" unless envelope["response"].present?

    JSON.parse(envelope["response"])
  rescue JSON::ParserError => e
    raise Erro, "O modelo não devolveu um JSON válido: #{e.message}"
  rescue Timeout::Error, Errno::ECONNREFUSED, SocketError => e
    raise Erro, "Não foi possível falar com o Ollama (#{BASE_URL}): #{e.message}"
  end
end
