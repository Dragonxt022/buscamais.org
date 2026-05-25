InvisibleCaptcha.setup do |config|
  config.timestamp_enabled       = true
  config.timestamp_threshold     = 4
  config.timestamp_error_message = "O formulário foi enviado rápido demais. Aguarde e tente novamente."
end
