abstract class Discovery::Routes::Base
  private getter config : Config

  def initialize(@config)
  end

  abstract def handle(env)
end
