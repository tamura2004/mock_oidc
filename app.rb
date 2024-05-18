require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/json"
require "securerandom"
require "jwt"

set :bind, "0.0.0.0"

get "/" do
  state = SecureRandom.uuid
  redirect_uri = "/auth"
  erb :home, locals: {state: state, redirect_uri: redirect_uri}
end

get "/auth" do
  state = params[:state]
  redirect_uri = params[:redirect_uri]
  erb :auth, locals: {state: state, redirect_uri: redirect_uri}
end

post "/login" do
  state = params[:state]
  uri = params[:redirect_uri]
  sub = params[:sub]
  redirect "#{uri}?code=#{sub}&state=#{state}"
end

get "/callback" do
end

post "/token", provides: :json do
  params = JSON.parse(request.body.read)
  code = params["code"]
  response = {
    access_token: code,
    token_type: "Bearer",
    expires_in: 3600,
    scope: "openid",
    id_token: generate_id_token(code)
  }
  json response
end

def generate_id_token(code)
  payload = {
    sub: code,
    iss: "http://localhost:4567",
    aud: "http://localhost:4567",
    exp: Time.now.to_i + 360,
  }
  JWT.encode(payload, nil, "HS256")
end
