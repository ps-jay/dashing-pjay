require 'dashing'

configure do
  # Disabled POST at nginx layer...
  set :auth_token, 'abcdefghijklmnopqrstuvwxyz'

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
