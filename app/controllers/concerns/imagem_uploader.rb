module ImagemUploader
  extend ActiveSupport::Concern

  private

  # Compresses and resizes an image upload before attaching.
  # Non-image files are returned unchanged.
  def processar_upload(upload)
    return fallback(upload) unless upload.content_type&.start_with?("image/")
    return fallback(upload) if upload.content_type == "image/gif"

    tempfile = ImageProcessing::Vips
      .source(upload.tempfile)
      .resize_to_limit(1920, 1920)
      .convert("jpeg")
      .saver(Q: 82, interlace: true, strip: true)
      .call

    nome = "#{File.basename(upload.original_filename, '.*')}.jpg"
    { nome: nome, tipo: "image/jpeg", tamanho: tempfile.size, tempfile: tempfile }
  rescue => e
    Rails.logger.error "[ImagemUploader] Falha ao comprimir imagem: #{e.message}"
    fallback(upload)
  end

  def fallback(upload)
    { nome: upload.original_filename, tipo: upload.content_type,
      tamanho: upload.size, tempfile: upload.tempfile }
  end

  def serializar_midia(m)
    return {} unless m.arquivo.attached?
    {
      id:        m.id,
      nome:      m.nome,
      descricao: m.descricao,
      tipo:      m.tipo,
      tamanho:   m.tamanho_formatado,
      url:       url_for(m.arquivo),
      signed_id: m.arquivo.blob.signed_id,
      sgid:      m.arquivo.blob.to_sgid.to_s
    }
  end
end
