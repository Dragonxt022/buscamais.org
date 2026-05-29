class SubscriptionHistory < ApplicationRecord
  belongs_to :user
  belongs_to :subscription_plan, optional: true

  EVENTOS = {
    "ativada"    => { label: "Assinatura iniciada",     cor: "green"  },
    "upgradada"  => { label: "Upgrade de plano",        cor: "blue"   },
    "downgradada"=> { label: "Downgrade de plano",      cor: "amber"  },
    "renovada"   => { label: "Renovação automática",    cor: "green"  },
    "cancelada"  => { label: "Cancelamento solicitado", cor: "red"    },
    "expirada"   => { label: "Expirada",                cor: "gray"   },
  }.freeze

  scope :recentes, -> { order(created_at: :desc) }

  def evento_label
    EVENTOS.dig(event_type, :label) || event_type.to_s.humanize
  end

  def evento_cor
    EVENTOS.dig(event_type, :cor) || "gray"
  end

  def vigente?
    vigente_ate.nil? || vigente_ate > Time.current
  end
end
