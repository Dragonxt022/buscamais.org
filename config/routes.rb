Rails.application.routes.draw do
  devise_for :users,
    path: "conta",
    path_names: { sign_in: "entrar", sign_out: "sair", sign_up: "cadastro", password: "senha" },
    controllers: {
      registrations:      "users/registrations",
      omniauth_callbacks: "users/omniauth_callbacks"
    }

  get "up" => "rails/health#show", as: :rails_health_check

  # Área pública
  root "noticias#index"

  get  "noticias",                        to: "noticias#index",     as: :noticias
  get  "noticias/:slug",                  to: "noticias#show",      as: :noticia
  get  "categoria/:slug",                 to: "noticias#categoria", as: :categoria
  post "comentarios",                     to: "comments#create",    as: :comentarios_publicos
  post   "comentarios/:id/curtir",    to: "comment_likes#toggle",    as: :curtir_comentario
  post   "comentarios/:id/salvar",    to: "comment_saves#create",    as: :salvar_comentario
  delete "comentarios/:id/salvar",    to: "comment_saves#destroy",   as: :dessalvar_comentario
  post   "comentarios/:id/denunciar", to: "comment_reports#create",  as: :denunciar_comentario

  post "cookie_consent", to: "cookie_consents#create", as: :cookie_consent

  # Planos e assinatura
  get  "planos",          to: "planos#index",  as: :planos_publicos
  get  "autores/:slug",   to: "autores#show",  as: :autor
  get  "busca",           to: "busca#index",   as: :busca

  # Stripe webhook
  post "stripe/webhook",  to: "stripe_webhooks#create", as: :stripe_webhook

  # Páginas institucionais
  get  "sobre-nos",   to: "paginas#sobre",          as: :sobre_nos
  get  "carreiras",   to: "paginas#carreiras",       as: :carreiras
  get  "contato",     to: "paginas#contato",         as: :contato
  post "contato",     to: "paginas#enviar_contato"
  get  "boletim",     to: "paginas#boletim",         as: :boletim
  post "boletim",     to: "paginas#assinar_boletim"
  get  "privacidade", to: "paginas#privacidade",     as: :privacidade
  get  "termos",      to: "paginas#termos",          as: :termos
  get  "mapa-do-site",to: "paginas#mapa_site",       as: :mapa_site
  get  "sitemap.xml", to: "paginas#sitemap",         as: :sitemap, defaults: { format: "xml" }

  # Área do usuário logado
  namespace :usuario do
    root "dashboard#index"
    resource  :perfil,      only: [:show, :edit, :update]
    resources :salvos,      only: [:index, :create, :destroy]
    resource  :assinatura,  only: [:show, :update] do
      member do
        post :checkout
        post :trocar_plano
        get  :sucesso
        get  :cancelado
      end
    end
    resources :follows, only: [:create] do
      collection { delete :destroy }
    end
    resources :comentarios, only: [:index]
    resources :notificacoes, only: [:index, :destroy] do
      collection do
        patch :marcar_todas_lidas
        delete :bulk_destroy
      end
      member { patch :marcar_lida }
    end
    get "configuracoes",    to: "configuracoes#edit"
    patch "configuracoes",  to: "configuracoes#update"
    get "resumo",           to: "resumos#show", as: :resumo
  end

  # Área do editor (editor + admin)
  namespace :editor do
    root "artigos#index"
    resources :artigos do
      member do
        patch :publicar
        patch :arquivar
      end
      collection { delete :bulk_destroy }
    end
    resources :midias, only: [:index, :create, :update, :destroy] do
      collection { delete :bulk_destroy }
    end
  end

  # Área administrativa (somente admin)
  namespace :admin do
    root "dashboard#index"
    resources :artigos do
      member do
        patch :publicar
        patch :arquivar
        patch :destacar
      end
      collection { delete :bulk_destroy }
    end
    resources :usuarios do
      member do
        patch :alterar_role
        patch :toggle_ativo
      end
      collection { delete :bulk_destroy }
    end
    resources :categorias do
      collection { delete :bulk_destroy }
    end
    resources :tags do
      collection { delete :bulk_destroy }
    end
    resources :comentarios, only: [:index, :show, :update, :destroy] do
      member do
        patch :aprovar
        patch :rejeitar
      end
      collection { delete :bulk_destroy }
    end
    resources :midias, only: [:index, :create, :update, :destroy] do
      collection { delete :bulk_destroy }
    end
    get "analise", to: "dashboard#analise"
    resource :configuracoes, only: [:show, :update]
    resources :notificacoes, only: [:index, :destroy] do
      collection { patch :marcar_todas_lidas }
    end
    resources :planos, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :assinaturas, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :mensagens, only: [:index, :show] do
      member { post :responder }
    end
  end
end
