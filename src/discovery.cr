require "kemal"
require "pg"
require "yaml"

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

class Discovery
  # TODO: Actually write code
end
