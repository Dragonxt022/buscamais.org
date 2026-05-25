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
  post "comentarios/:id/curtir",          to: "comment_likes#toggle", as: :curtir_comentario

  post "cookie_consent", to: "cookie_consents#create", as: :cookie_consent

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
    resource  :assinatura,  only: [:show, :update]
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
  end
end
