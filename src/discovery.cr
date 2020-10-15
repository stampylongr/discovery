require "kemal"
require "pg"
require "yaml"
require "./discovery/auth"
require "./discovery/user"

CONFIG_STR = ENV.has_key?(ENV_CONFIG_NAME) ? ENV.fetch(ENV_CONFIG_NAME) : File.read("config/config.yml")
CONFIG     = Config.from_yaml(CONFIG_STR)

PG_URL = URI.new(
  scheme: "postgres",
  user: CONFIG.db.user,
  password: CONFIG.db.password,
  host: CONFIG.db.host,
  port: CONFIG.db.port,
  path: CONFIG.db.dbname,
)

PG_DB           = DB.open PG_URL

CURRENT_BRANCH  = {{ "#{`git branch | sed -n '/* /s///p'`.strip}" }}
CURRENT_COMMIT  = {{ "#{`git rev-list HEAD --max-count=1 --abbrev-commit`.strip}" }}
CURRENT_VERSION = {{ "#{`git describe --tags --abbrev=0`.strip}" }}

ASSET_COMMIT = {{ "#{`git rev-list HEAD --max-count=1 --abbrev-commit -- assets`.strip}" }}

SOFTWARE = {
  "name"    => "discovery",
  "version" => "#{CURRENT_VERSION}-#{CURRENT_COMMIT}",
  "branch"  => "#{CURRENT_BRANCH}",
}

config = CONFIG

Kemal::Session.config do |config|
  config.cookie_name = "sess_id"
  config.secret = CONFIG.secret
  config.gc_interval = 1.minutes
end

class UserStorableObject
  JSON.mapping({
    id_token: String
  })

  include Kemal::Session::StorableObject

  def initialize(@id_token : String); end
end

Discovery::Routing.get "/", Discovery::Routes::Home

get "/auth/login" do |env|
  env.redirect("#{CONFIG.auth0.domain}/authorize?client=#{CONFIG.auth0.pubkey}")
end

get "/auth/callback" do |env|
  code = env.params.query["code"]
  jwt = Auth.get_auth_token(code)
  env.response.headers["Authorization"] = "Bearer #{jwt}"  # Set the Auth header with JWT.

  user = UserStorableObject.new(jwt)
  env.session.object("user", user)

  env.redirect "/success"
end

get "/success" do |env|
  user = env.session.object("user").as(UserStorableObject)
  env.response.headers["Authorization"] = "Bearer #{user.id_token}"

  render "src/discovery/views/success.ecr", "src/discovery/views/layout.ecr"
end

get "/auth/logout" do |env|
  env.session.destroy

  render "src/discovery/views/logout.ecr", "src/discovery/views/layout.ecr"
end

before_get "/challenges" do |env|
  user = env.session.object("user").as(UserStorableObject)

  auth = User.authorised?(user.id_token)
  raise "Unauthorized" unless auth = true
end
