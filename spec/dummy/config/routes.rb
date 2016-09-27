Rails.application.routes.draw do
  get '/test/public', to: 'test#public'
  get '/test/admin_only', to: 'test#admin_only'
  get '/test/no_access', to: 'test#no_access'
end
