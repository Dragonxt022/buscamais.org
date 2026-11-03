class GerarMateriaIaJob < ApplicationJob
  queue_as :default

  def perform(usuario_id:, categoria_id:, assunto:, categorias_extra_ids: [], rumo: nil,
              tags_sugeridas: nil, palavra_chave_foco: nil, tamanho: "medio", dados_referencia: nil)
    usuario   = User.find(usuario_id)
    categoria = Category.find(categoria_id)
    extras    = Category.where(id: categorias_extra_ids)

    resultado = GeradorMateriaIa.new(
      autor: usuario, categoria: categoria, categorias_extra: extras,
      assunto: assunto, rumo: rumo, tags_sugeridas: tags_sugeridas,
      palavra_chave_foco: palavra_chave_foco, tamanho: tamanho,
      dados_referencia: dados_referencia
    ).chamar

    if resultado.sucesso?
      Notification.notificar_materia_ia_pronta(usuario, resultado.artigo)
    else
      Notification.notificar_materia_ia_falhou(usuario, assunto, resultado.erro)
    end
  end
end
