class Admin::MidiasController < Admin::BaseController
  include ImagemUploader
  include ActionView::Helpers::NumberHelper

  def index
    scope = MediaFile.includes(arquivo_attachment: :blob).recentes
    scope = scope.imagens if params[:apenas_imagens].present?
    scope = scope.where("nome LIKE ?", "%#{params[:q]}%") if params[:q].present?
    if params[:album_id] == "sem_album"
      scope = scope.where(album_id: nil)
    elsif params[:album_id].present?
      scope = scope.where(album_id: params[:album_id])
    end
    @albuns = Album.ordenados
    @pagy, @midias = pagy(scope, limit: 30)

    respond_to do |format|
      format.html
      format.json do
        render json: {
          midias: @midias.map { |m| serializar_midia(m) },
          total: @pagy.count
        }
      end
    end
  end

  def create
    uploads = Array(params[:media_file]&.dig(:arquivo)).flatten.select(&:present?)

    if uploads.empty?
      respond_to do |format|
        format.html { redirect_to admin_midias_path, alert: "Nenhum arquivo selecionado." }
        format.json { render json: { errors: ["Nenhum arquivo selecionado."] }, status: :unprocessable_entity }
      end
      return
    end

    salvos  = []
    erros   = []

    uploads.each do |upload|
      midia     = MediaFile.new(user: current_user)
      processado = processar_upload(upload)
      midia.nome    = processado[:nome]
      midia.tipo    = processado[:tipo]
      midia.tamanho = processado[:tamanho]
      midia.arquivo.attach(
        io:           processado[:tempfile],
        filename:     processado[:nome],
        content_type: processado[:tipo]
      )
      if midia.save
        salvos << midia
      else
        erros << "#{processado[:nome]}: #{midia.errors.full_messages.join(', ')}"
      end
    end

    respond_to do |format|
      if erros.empty?
        msg = salvos.size == 1 ? "Arquivo enviado com sucesso." : "#{salvos.size} arquivos enviados."
        format.html { redirect_to admin_midias_path, notice: msg }
        format.json { render json: salvos.map { |m| serializar_midia(m) }, status: :created }
      else
        format.html { redirect_to admin_midias_path, alert: erros.join(" | ") }
        format.json { render json: { errors: erros }, status: :unprocessable_entity }
      end
    end
  end

  def update
    @midia = MediaFile.find(params[:id])
    respond_to do |format|
      if @midia.update(midia_params)
        format.html { redirect_to admin_midias_path, notice: "Arquivo atualizado." }
        format.json { render json: serializar_midia(@midia) }
      else
        format.html { redirect_to admin_midias_path, alert: @midia.errors.full_messages.join(", ") }
        format.json { render json: { errors: @midia.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @midia = MediaFile.find(params[:id])
    @midia.arquivo.purge if @midia.arquivo.attached?
    @midia.destroy

    respond_to do |format|
      format.html { redirect_to admin_midias_path, notice: "Arquivo removido." }
      format.json { head :no_content }
    end
  end

  def bulk_destroy
    ids = Array(params[:ids]).map(&:to_i)
    midias = MediaFile.where(id: ids)
    midias.each { |m| m.arquivo.purge if m.arquivo.attached? }
    count = midias.destroy_all.size

    respond_to do |format|
      format.html { redirect_to admin_midias_path, notice: "#{count} arquivo(s) removido(s)." }
      format.json { render json: { deleted: count } }
    end
  end

  private

  def midia_params
    params.require(:media_file).permit(:nome, :descricao, :album_id)
  end
end
