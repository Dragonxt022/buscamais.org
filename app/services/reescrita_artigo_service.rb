# Reescreve uma matéria já importada, substituindo o texto original pela
# versão gerada pela IA. Usado pelo botão "Reescrever com IA" e pelo
# reprocessamento em lote do painel.
class ReescritaArtigoService
  Resultado = Struct.new(:sucesso, :erro, :artigo, keyword_init: true) do
    def sucesso?
      sucesso
    end
  end

  def initialize(artigo)
    @artigo = artigo
    @feed   = artigo&.feed_source
  end

  def chamar
    status_anterior = @artigo&.reescrita_status

    return falha("Artigo não encontrado") if @artigo.nil?
    return falha("O artigo não foi importado de um feed RSS") if @feed.nil?
    return falha_com_status("O artigo não tem URL de origem") if @artigo.fonte_url.blank?

    html = conteudo_atual
    return falha_com_status("O artigo não tem conteúdo para reescrever") if html.blank?

    # Trava o artigo para que dois cliques no reprocessamento não peguem o
    # mesmo item. O job em lote também usa esse status para montar o próximo lote.
    @artigo.update_columns(reescrita_status: "processando", updated_at: Time.current)

    resultado = ReescritaEditorial.new(
      titulo: titulo_original,
      conteudo: html,
      fonte_nome: @artigo.fonte_nome.presence || @feed.nome,
      fonte_url: @artigo.fonte_url,
      categoria: @artigo.category&.nome,
      data: @artigo.publicado_em,
      # O botão é uma ação manual: funciona mesmo com a reescrita automática
      # desligada, desde que exista um modelo configurado.
      ignorar_desativacao: true
    ).chamar

    unless resultado.sucesso?
      marcar_falha(status_anterior)
      return falha(resultado.erro)
    end

    aplicar_reescrita(resultado)
    Resultado.new(sucesso: true, artigo: @artigo)
  rescue => e
    marcar_falha(status_anterior) if @artigo.present?
    Rails.logger.error("[ReescritaArtigoService:#{@artigo&.id}] #{e.class}: #{e.message}")
    falha("Falha inesperada na reescrita: #{e.message}".truncate(300))
  end

  private

  def conteudo_atual
    html = @artigo.conteudo&.body&.to_html.to_s
    return html if html.present?

    @artigo.conteudo.to_s
  end

  # Para reescritas sucessivas, o título atual já é o da IA. Nesse caso o
  # título original do feed não existe mais; usamos o próprio atual como
  # referência para evitar repetição.
  def titulo_original
    @artigo.titulo
  end

  def aplicar_reescrita(resultado)
    @artigo.preservar_slug = true
    @artigo.update!(
      titulo: resultado.titulo,
      resumo: resultado.resumo,
      conteudo: resultado.conteudo,
      palavra_chave_foco: resultado.palavra_chave.presence,
      reescrita_status: "reescrito",
      reescrita_modelo: resultado.modelo,
      fonte_nome: @artigo.fonte_nome.presence || @feed.nome,
      mostrar_fonte: true
    )
    aplicar_tags(resultado.tags)
  end

  def aplicar_tags(tags)
    nomes = Array(tags).map { |nome| nome.to_s.squish.delete_prefix("#") }
                        .reject(&:blank?)
                        .uniq(&:downcase)
                        .first(5)
    return if nomes.empty?

    @artigo.tags = nomes.map { |nome| Tag.find_or_create_by!(nome: nome) }
  rescue => e
    Rails.logger.warn("[ReescritaArtigoService:#{@artigo.id}] tags: #{e.message}")
  end

  def marcar_falha(status_anterior)
    # Se a matéria já era uma reescrita válida, uma nova tentativa com falha
    # não deve apagar o resultado anterior.
    if status_anterior == "reescrito"
      @artigo.update_columns(reescrita_status: "reescrito", updated_at: Time.current)
    else
      @artigo.update_columns(reescrita_status: "falhou", updated_at: Time.current)
    end
  rescue => e
    Rails.logger.warn("[ReescritaArtigoService:#{@artigo.id}] marcar falha: #{e.message}")
  end

  # Em lote, o job marca o artigo como "processando" antes de chamar o
  # serviço. Se a validação falhar, precisamos liberar esse status.
  def falha_com_status(mensagem)
    marcar_falha(@artigo.reescrita_status) if @feed.present?
    falha(mensagem)
  end

  def falha(mensagem)
    Resultado.new(sucesso: false, erro: mensagem.to_s.truncate(300), artigo: @artigo)
  end
end
