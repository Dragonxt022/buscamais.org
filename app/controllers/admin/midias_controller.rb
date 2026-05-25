class Admin::MidiasController < Admin::BaseController
  include ImagemUploader
  include ActionView::Helpers::NumberHelper

  def index
    scope = MediaFile.includes(arquivo_attachment: :blob).recentes
    scope = scope.imagens if params[:apenas_imagens].present?
    scope = scope.where("nome LIKE ?", "%#{params[:q]}%") if params[:q].present?
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
    @midia = MediaFile.new(user: current_user)

    if params[:media_file]&.dig(:arquivo).present?
      upload    = params[:media_file][:arquivo]
      processado = processar_upload(upload)
      @midia.nome    = processado[:nome]
      @midia.tipo    = processado[:tipo]
      @midia.tamanho = processado[:tamanho]
      @midia.arquivo.attach(
        io:           processado[:tempfile],
        filename:     processado[:nome],
        content_type: processado[:tipo]
      )
    end

    respond_to do |format|
      if @midia.save
        format.html { redirect_to admin_midias_path, notice: "Arquivo enviado com sucesso." }
        format.json { render json: serializar_midia(@midia), status: :created }
      else
        format.html { redirect_to admin_midias_path, alert: @midia.errors.full_messages.join(", ") }
        format.json { render json: { errors: @midia.errors.full_messages }, status: :unprocessable_entity }
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
    params.require(:media_file).permit(:nome, :descricao)
  end
end
