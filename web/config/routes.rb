Rails.application.routes.draw do
  devise_for :administrators, path: "admin", controllers: { sessions: "admin/sessions" }
  devise_for :accounts, path: "studios", controllers: { sessions: "studios/sessions" }
  namespace :admin do
    root "dashboards#show"
    resources :studios do
      resources :invitations, only: %i[index new create] do
        member { patch :cancel }
      end
    end
  end

  scope "studios", module: :studios do
    get "sign_up", to: "registrations#new", as: :new_studio_registration
    post "sign_up", to: "registrations#create", as: :studio_registration
    get "sign_up/invalid", to: "registrations#invalid", as: :invalid_studio_registration
  end

  scope "studios/:studio_slug", module: :studios, as: :studio do
    root "dashboards#show"
    resources :memberships, only: %i[index]
    resources :invitations, only: %i[index new create]

    resources :ideas, only: %i[index create edit update] do
      resource :archive, only: %i[create destroy]
    end

    resources :archived_ideas, path: "ideas/archived", only: %i[index destroy]

    resources :zines do
      resource :page_order, only: %i[update]
      resource :publication, only: %i[create destroy]

      resources :pages do
        member do
          patch :submit
          patch :confirm
          patch :send_back
        end

        resource :writing, only: %i[edit update]
      end
    end
  end

  root "homes#show"
  resource :about, only: %i[show]
  resources :zines, only: %i[index show]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
