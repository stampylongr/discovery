class Discovery::Routes::Home < Discovery::Routes::Base
  def handle(env)
    user = env.get? "user"

    if user
      templated "home"
    else
      templated "welcome"
    end
  end
end
