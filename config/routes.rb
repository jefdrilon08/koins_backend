Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      post "/login", to: "authentication#login"
      post "member/login", to: "member_authentication#login"

      resources :billings, only: [:index, :show, :create] do 
        collection do
          post :sync # for offline sync
        end
      end
      #resources :students
      namespace :member do
        resources :shares, only: [:index]
        resources :accounts, only: [:index] do 
          collection do
            get :equity
          end
        end

        get "loans", to: "loans#index"
        get "loans/:loan_id/amortization_schedule",
          to: "amortization_schedule#index"

        get "/transactions/:account_id",
        to: "transactions#index"

      end
    end
  end

end
