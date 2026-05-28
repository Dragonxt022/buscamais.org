class Admin::AssinaturasController < Admin::BaseController

  before_action :carregar_assinatura, only: [:show, :edit, :update, :destroy]

  def index
    scope = Subscription.includes(:user, :plan).order(updated_at: :desc)
    scope = scope.where(status: params[:status])             if params[:status].present?
    scope = scope.where(subscription_plan_id: params[:plan]) if params[:plan].present?
    if params[:q].present?
      scope = scope.joins(:user)
                   .where("users.nome LIKE ? OR users.email LIKE ?",
                          "%#{params[:q]}%", "%#{params[:q]}%")
    end
    @planos = SubscriptionPlan.ordenados
    @pagy, @assinaturas = pagy(scope, limit: 25)
  end

  def show; end

  def new
    @assinatura = Subscription.new(status: :ativa)
    @usuarios   = User.order(:nome)
    @planos     = SubscriptionPlan.ativos.ordenados
  end

  def create
    @assinatura = Subscription.new(assinatura_params)
    if @assinatura.save
      redirect_to admin_assinaturas_path, notice: "Assinatura criada."
    else
      @usuarios = User.order(:nome)
      @planos   = SubscriptionPlan.ativos.ordenados
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @usuarios = User.order(:nome)
    @planos   = SubscriptionPlan.ativos.ordenados
  end

  def update
    if @assinatura.update(assinatura_params)
      redirect_to admin_assinaturas_path, notice: "Assinatura atualizada."
    else
      @usuarios = User.order(:nome)
      @planos   = SubscriptionPlan.ativos.ordenados
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @assinatura.destroy
    redirect_to admin_assinaturas_path, notice: "Assinatura removida."
  end

  private

  def carregar_assinatura
    @assinatura = Subscription.find(params[:id])
  end

  def assinatura_params
    params.require(:subscription).permit(
      :user_id, :subscription_plan_id, :status, :plano,
      :stripe_customer_id, :stripe_subscription_id, :prox_cobranca
    )
  end
end
