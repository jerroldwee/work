FigoRails::Application.routes.draw do

  # get "credits/index"
  # get "credits/wall"
  # get "credits/first_login"
  # post "users/login"
  # post "users/invite_friends"
  # get "wall/index"
  # get "wall/show"
  # post "wall/create"
  # delete "wall/destroy"
  # get "products/product_types"
  # get "products/show"
  # get "products/index"

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
  get "login" => "sessions#new", :as => "log_in"
  get "signup" => "users#new", :as => "sign_up" 
  get 'admin', to: redirect('/admin/products')

  resources :sessions 

  namespace :api do
    resources :products do 
      collection do
        get 'product_types'
        get 'men'
        get 'women'
        get 'unisex'

        post 'product_types'
        post 'men'
        post 'women'
        post 'unisex'
      end
    end
    resources :wall do 
      collection do
        post 'create'
      end
    end
    resources :users do 
      collection do
        post 'invite_friends'
        get 'invite_friends'
        get 'login'
        post 'login'
      end
    end
    resources :credits do 
      collection do
        get 'wall'
        post 'wall'

        get 'first_login'
        post 'first_login'
      end
    end
    resources :promotions
  end

  resources "users" do
    collection do
      get 'visual_try_on'
      post 'delete_wall'
    end
    resources :orders
  end

  namespace :admin do
    resources :products do
      resources :choices do
        resources :product_images do
          collection do
            post 'reorder'
          end
        end
      end
      resources :model_images do
        collection do
          post 'reorder'
        end
      end
      resources :fit_room_images
    end
    resources :promotions
    resources :settings
    resources :orders do
      resources :line_items
      collection do 
        post 'csv'
      end
    end
    resources :lens
    resources :users do 
      member do 
        get :photos
      end
    end
    resources :moderators
  end

  resources :products do 
    collection do
      get 'partial_list'
      get 'men'
      get 'women'
      get 'unisex'
    end
    member do
      get 'details'
    end
  end

  resources :user_fit_rooms do
    collection do
      post 'save'
    end
  end

  resources :facebook do
    collection do
      get 'channel'
      get 'details'
      post 'invited'
      post 'posted'
    end
  end

  resources :line_items
  resources :prescriptions
  resources :billing_addresses

  resources :carts do
    collection do
      post 'save'
      get 'billing'
      post 'billing'
      get 'verify'
      get 'payment'
      post 'payment'
      get 'thank_you'
    end
    member do
      get 'payment'
      post 'payment'
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'pages#index'

  get '/about' => 'pages#about'
  get '/faq' => 'pages#faq'
  get '/philosophy' => 'pages#philosophy'
  get '/returns' => 'pages#returns'
  get '/privacy' => 'pages#privacy'
  get '/terms' => 'pages#terms'
  get '/referral' => 'pages#referral'
  get '/contactus' => 'pages#contactus'
  get '/apps' => 'pages#apps'
  get '/contest' => 'pages#contest'

  get '/help' => 'pages#help'


  get '/comingsoon' => 'pages#comingsoon'
  post '/' => 'pages#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
