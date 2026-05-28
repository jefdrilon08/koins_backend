Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      post "/login", to: "authentication#login"
      post "member/login", to: "member_authentication#login"
      get "/users/:user_id/branches_centers",
        to: "users#branches_centers"
      get "project_type_categories",
        to: "project_types#categories"

      get "project_types",
        to: "project_types#index"
        
      #namespace :addresses do
      #  get :regions,        to: "addresses#regions"
      #  get :provinces,      to: "addresses#provinces"
      #  get :municipalities, to: "addresses#municipalities"
      #  get :barangays,      to: "addresses#barangays"
      #end

      namespace :addresses do
        get "regions",            to: "addresses#regions"
        get "provinces",      to: "addresses#provinces"
        get "municipalities", to: "addresses#municipalities"
        get "barangays",      to: "addresses#barangays"
      end

      resources :branches, only: [:index] do
        get :centers, on: :member
      end

      resources :billings, only: [:index, :show, :create] do 
        collection do
          post :sync # for offline sync
        end
      end
      #resources :students
      get "/health", to: proc { [200, {}, ["OK"]] }

      namespace :member do
        resources :co_makers, only: [:index]
        resources :shares, only: [:index]
        post "/register",
          to: "registrations#create"
        #resource :change_password, only: [:update]
        post "change_password",
          to: "change_passwords#update"
        resources :accounts, only: [:index] do 
          collection do
            get :equity
          end
        end

        resources :beneficiaries, only: [:create]
        get "check_mobile",    to: "registrations#check_mobile"
        get "check_duplicate", to: "registrations#check_duplicate"
        
         get "loans/applications", to: "loans#applications"  
        get "loans", to: "loans#index"
      
        get "loans/:loan_id/amortization_schedule",
          to: "amortization_schedule#index"

        get "/transactions/:account_id",
        to: "transactions#index"
      
      resources :loan_products,
        only: [:index]

      resources :loan_applications,
        only: [:index, :create]

      end

    end
  end

end
