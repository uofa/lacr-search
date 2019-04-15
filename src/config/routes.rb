Rails.application.routes.draw do

  devise_scope :user do
    get "/sign_in" => "devise/sessions#new" # custom path to login/sign_in
    get 'login', to: 'devise/sessions#new'
    get "/sign_up" => "devise/registrations#new", as: "new_user_registration" # custom path to sign_up/registration
  end

  devise_for :users

  # Home page routes
  root to: 'home#index'
  get '/about', to: 'home#about'
  get '/contact', to: 'home#contact'

  # Documents page routes
  get 'doc', to: "documents#index"
  get 'doc/new', to: "documents#new"
  post 'doc/new', to: "documents#upload"
  get 'doc/show', to: "documents#show"
  get 'doc/page', to: "documents#page"
  get 'doc/page-s', to: "documents#page_simplified"
  get 'doc/selected', to: "documents#selected"
  delete 'doc/destroy', to: "documents#destroy"

  # Download
  get 'download/archive', to: "download#archive"

  # Ajax
  post 'ajax/download', to: "download#index"
  get 'ajax/doc/selected/pdf', to: "download#selected_gen_pdf"
  post 'ajax/doc/destroy', to: "documents#destroy"
  get 'ajax/doc/list', to: "documents#list"
  get 'ajax/search/autocomplete', to: 'search#autocomplete'
  get 'ajax/search/autocomplete-entry', to: 'search#autocomplete_entry'
  get 'ajax/search/chart/worddate', to: 'search#chart_wordstart_date'

  # Search routes
  get 'search', to: 'search#search'
  get 'query', to: 'xquery#index'
  post 'query', to: 'xquery#show'
end
