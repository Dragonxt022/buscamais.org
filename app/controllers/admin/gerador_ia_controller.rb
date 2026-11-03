class Admin::GeradorIaController < Admin::BaseController
  def new
    @categorias = Category.ativas.order(:nome)
  end

  def create
    GerarMateriaIaJob.perform_later(**gerador_params)
    flash[:notice] = "Gerando matéria com IA... você será notificado quando estiver pronta (pode levar alguns minutos)."
    redirect_to admin_artigos_path
  end

  private

  def gerador_params
    {
      usuario_id:            current_user.id,
      categoria_id:          params[:categoria_id],
      categorias_extra_ids:  Array(params[:categorias_extra_ids]).reject(&:blank?),
      assunto:               params[:assunto],
      rumo:                  params[:rumo].presence,
      tags_sugeridas:        params[:tags_sugeridas].presence,
      palavra_chave_foco:    params[:palavra_chave_foco].presence,
      tamanho:               params[:tamanho].presence || "medio",
      dados_referencia:      params[:dados_referencia].presence
    }
  end
end
