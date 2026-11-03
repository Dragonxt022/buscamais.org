# Só inicia o agendador no processo do servidor web (rails server / Puma).
# Em comandos como `rails runner`, `rails db:migrate` e no console ele não sobe.
# Para rodar em outro tipo de servidor, defina FEED_SCHEDULER_ENABLED=1.
Rails.application.config.after_initialize do
  if ENV["FEED_SCHEDULER_DISABLED"].blank? &&
     (defined?(Rails::Server) || ENV["FEED_SCHEDULER_ENABLED"] == "1")
    FeedScheduler.start
  end
end
