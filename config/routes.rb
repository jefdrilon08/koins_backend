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
      get "/health", to: proc { [200, {}, ["OK"]] }
    end
  end

end
