# Verifica a cada minuto se alguma fonte RSS venceu o intervalo configurado e
# dispara a importação. Roda dentro do processo do Puma (uma única instância
# nesta VPS), sem depender de cron ou de um worker separado.
class FeedScheduler
  INTERVALO_SEGUNDOS = 60

  class << self
    def start
      return @thread if @thread&.alive?

      @thread = Thread.new do
        Thread.current.name = "feed-scheduler" if Thread.current.respond_to?(:name=)
        Rails.logger.info("[FeedScheduler] iniciado (verificação a cada #{INTERVALO_SEGUNDOS}s)")

        loop do
          tick
          sleep INTERVALO_SEGUNDOS
        end
      end
      @thread.abort_on_exception = false
      @thread
    end

    def tick
      Rails.application.executor.wrap do
        FeedSource.ativos.to_a.select(&:devido?).each do |feed|
          ActiveRecord::Base.connection_pool.with_connection { feed.sincronizar! }
        rescue => e
          Rails.logger.error("[FeedScheduler] #{feed.nome}: #{e.class}: #{e.message}")
        end
      end
    rescue => e
      Rails.logger.error("[FeedScheduler] #{e.class}: #{e.message}")
    end

    def stop
      @thread&.kill
      @thread = nil
    end
  end
end
