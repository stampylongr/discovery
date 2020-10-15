require "http/client"
require "json"

module Auth
  extend self

  def get_auth_token(id_code)
    id = id_code

    uri = URI.parse("#{CONFIG.auth0.domain}/oauth/token")

    request = HTTP::Client.post(uri,
      headers: HTTP::Headers{"content-type" => "application/json"},
      body: "{\"grant_type\":\"authorization_code\",\"client_id\": \"#{CONFIG.auth0.pubkey}\",\"client_secret\": \"#{CONFIG.auth0.privkey}\",\"code\": \"#{id}\",\"redirect_uri\": \"#{CONFIG.hostname}/auth/callback\"}")

    response = request.body

    res = get_jwt(response)
    return res
  end

  class Token
    JSON.mapping(
      access_token: String,
      id_token: String,
      expires_in: Int32,
      token_type: String,
    )
  end

  def get_jwt(auth_code)
    auth = auth_code

    value = Token.from_json(%(#{auth}))
    jwt = value.id_token

    return jwt
  end

end
