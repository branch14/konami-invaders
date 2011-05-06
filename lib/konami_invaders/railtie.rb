module KonamiInvaders

  case Rails.version.to_i
  when 2
    Rails.configuration.middleware.use KonamiInvaders::Middleware

  when 3
    class Railtie < Rails::Railtie
      initializer "konami_invaders.insert_middleware" do |app|
        app.config.middleware.use "KonamiInvaders::Middleware"
      end
    end
  else
    raise "Unknown Rails version"
  end

end

