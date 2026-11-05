# Sincronização manual disparada pelo painel. Roda fora da requisição HTTP
# porque a reescrita com IA pode levar minutos por matéria.
class FeedSyncJob < ApplicationJob
  queue_as :default

  def perform(feed_id)
    feed = FeedSource.find_by(id: feed_id)
    return if feed.nil?

    feed.sincronizar!
  rescue => e
    Rails.logger.error("[FeedSyncJob] feed #{feed_id}: #{e.class}: #{e.message}")
  end
end
