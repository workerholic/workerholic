Rails.application.routes.draw do
  root 'jobs#index'

  post "add", to: "jobs#create"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
