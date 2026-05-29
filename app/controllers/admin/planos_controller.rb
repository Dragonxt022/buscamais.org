class Admin::PlanosController < Admin::BaseController
  before_action :set_plano, only: [:edit, :update, :destroy]

  def index
    @planos = SubscriptionPlan.ordenados
  end

  def new
    @plano = SubscriptionPlan.new(posicao: SubscriptionPlan.maximum(:posicao).to_i + 1)
  end

  def create
    @plano = SubscriptionPlan.new(plano_params)
    if @plano.save
      redirect_to admin_planos_path, notice: "Plano \"#{@plano.nome}\" criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @plano.update(plano_params)
      redirect_to edit_admin_plano_path(@plano), notice: "Plano \"#{@plano.nome}\" salvo com sucesso.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    nome = @plano.nome
    @plano.destroy
    redirect_to admin_planos_path, notice: "Plano \"#{nome}\" removido."
  end

  private

  def set_plano
    @plano = SubscriptionPlan.find(params[:id])
  end

  def plano_params
    permissoes_tratadas = {}
    if params[:plano][:permissoes].present?
      SubscriptionPlan::PERMISSOES_DEFINICOES.each_key do |chave|
        val = params[:plano][:permissoes][chave]
        next if val.nil?

        defn = SubscriptionPlan::PERMISSOES_DEFINICOES[chave]
        permissoes_tratadas[chave] = case defn[:tipo]
                                     when :boolean then val == "1"
                                     when :numero  then val.to_i
                                     else           val.presence
                                     end
      end
    end

    beneficios_tratados = Array(params[:plano][:beneficios])
                           .map(&:strip).reject(&:blank?)

    params.require(:plano).permit(
      :nome, :slug, :descricao, :preco, :posicao, :destaque, :ativo, :cor,
      :promocao_ativa, :preco_promocional, :meses_promocionais,
      :stripe_price_id, :stripe_promo_price_id, :apenas_novos_usuarios
    ).merge(beneficios: beneficios_tratados, permissoes: permissoes_tratadas)
  end
end
