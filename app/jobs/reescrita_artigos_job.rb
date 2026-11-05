# Reprocessa matérias já importadas com a IA local.
#
# Sem `artigo_id`, pega as matérias ainda com o texto original (nunca
# reescritas, com reescrita desativada ou que falharam) e processa no máximo
# `limite` por execução. Já reescritas ficam de fora, então cliques seguidos
# avançam para o próximo lote.
class ReescritaArtigosJob < ApplicationJob
  queue_as :default

  LIMITE_MAXIMO = 100
  LIMITE_PADRAO = 20
  TRAVA_EXPIRADA = 1.hour

  # Evita dois lotes simultâneos no mesmo processo (cliques repetidos).
  LOCK = Mutex.new

  def perform(feed_id: nil, artigo_id: nil, limite: LIMITE_PADRAO)
    if artigo_id.present?
      artigo = Article.find_by(id: artigo_id)
      return if artigo.nil?
      return if artigo.reescrita_status == "processando" && artigo.updated_at > 1.hour.ago

      ReescritaArtigoService.new(artigo).chamar
      return
    end

    unless LOCK.try_lock
      Rails.logger.info("[ReescritaArtigosJob] já existe um lote em andamento")
      return
    end

    begin
      processar_lote(feed_id: feed_id, limite: limite)
    ensure
      LOCK.unlock
    end
  rescue => e
    Rails.logger.error("[ReescritaArtigosJob] #{e.class}: #{e.message}")
  end

  private

  def processar_lote(feed_id:, limite:)
    # Se um processo morreu no meio, devolve os itens travados para a fila.
    Article.importados
           .where(reescrita_status: "processando")
           .where("updated_at < ?", TRAVA_EXPIRADA.ago)
           .update_all(reescrita_status: "falhou", updated_at: Time.current)

    limite = limite.to_i
    limite = LIMITE_PADRAO if limite <= 0
    limite = limite.clamp(1, LIMITE_MAXIMO)

    scope = Article.importados
                   .includes(:feed_source, :category)
                   .where(reescrita_status: [ nil, "desativada", "falhou" ])
                   .where.not(fonte_url: [ nil, "" ])
                   .where.not(status: Article.statuses["arquivado"])
    scope = scope.where(feed_source_id: feed_id) if feed_id.present?
    artigos = scope
             .order(Arel.sql("CASE WHEN reescrita_status IS NULL OR reescrita_status = 'desativada' THEN 0 ELSE 1 END"))
             .order(publicado_em: :desc)
             .limit(limite)
             .to_a

    if artigos.empty?
      Rails.logger.info("[ReescritaArtigosJob] nenhuma matéria pendente")
      return [ 0, 0 ]
    end

    # Reserva o lote inteiro antes de começar, para que outro clique não
    # pegue os mesmos artigos enquanto a IA trabalha.
    Article.where(id: artigos.map(&:id))
           .update_all(reescrita_status: "processando", updated_at: Time.current)

    total = 0
    sucessos = 0

    artigos.each do |artigo|
      resultado = ReescritaArtigoService.new(artigo).chamar
      total += 1
      sucessos += 1 if resultado.sucesso?
    end

    Rails.logger.info("[ReescritaArtigosJob] #{sucessos}/#{total} matéria(s) reescrita(s)")
    [ sucessos, total ]
  end
end
