require "jwt"
require "json"

module User
  extend self

  @@verify_key = CONFIG.auth0.privkey

  def authorised?(user)
    token = user
    payload, header = JWT.decode(token, @@verify_key, "HS256")
    roles = payload["app_metadata"].to_s
    rs = roles.includes?("member")
    puts rs

    return
  end

end
