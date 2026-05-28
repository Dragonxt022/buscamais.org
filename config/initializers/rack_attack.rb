class Rack::Attack
  ### Throttles ###

  # Login: 5 tentativas por 20 segundos por IP
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/conta/entrar" && req.post?
  end

  # Login: 10 tentativas por 5 minutos por e-mail
  throttle("logins/email", limit: 10, period: 5.minutes) do |req|
    if req.path == "/conta/entrar" && req.post?
      req.params.dig("user", "email").to_s.downcase.strip.presence
    end
  end

  # Cadastro: 3 contas por hora por IP (evita criação em massa)
  throttle("signup/ip", limit: 3, period: 1.hour) do |req|
    req.ip if req.path == "/conta/cadastro" && req.post?
  end

  # Comentários: 10 por minuto por IP (spam de comentários)
  throttle("comentarios/ip", limit: 10, period: 1.minute) do |req|
    req.ip if req.path == "/comentarios" && req.post?
  end

  # Busca: 30 por minuto por IP (scraping)
  throttle("busca/ip", limit: 30, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/busca")
  end

  # API geral: 300 req/minuto por IP
  throttle("req/ip", limit: 300, period: 1.minute) do |req|
    req.ip unless req.path.start_with?("/assets", "/packs")
  end

  ### Blocklist ###

  # Bloqueia IPs que tentaram login mais de 20x em 5 minutos
  blocklist("block aggressive login/ip") do |req|
    Rack::Attack::Allow2Ban.filter(req.ip, maxretry: 20, findtime: 5.minutes, bantime: 1.hour) do
      req.path == "/conta/entrar" && req.post?
    end
  end

  ### Resposta para throttled requests ###
  self.throttled_responder = lambda do |env|
    retry_after = (env["rack.attack.match_data"] || {})[:period]
    [
      429,
      {
        "content-type" => "application/json",
        "retry-after"  => retry_after.to_s
      },
      [{ error: "Muitas requisições. Tente novamente em instantes." }.to_json]
    ]
  end
end
