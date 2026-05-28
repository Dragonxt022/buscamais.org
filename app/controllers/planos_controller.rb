class PlanosController < ApplicationController
  def index
    @planos = SubscriptionPlan.ativos.ordenados
    @plano_atual = user_signed_in? ? current_user.plano_atual : nil
  end
end
