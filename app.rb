require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/json"
require "securerandom"
require "jwt"
require "net/http"

BASE_URL = ENV["BASE_URL"] || "http://localhost:4567"

set :bind, "0.0.0.0"

get "/" do
  state = SecureRandom.uuid
  redirect_uri = "/callback"
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
  iss = "https://example.com"
  redirect "#{uri}?code=#{sub}&state=#{state}&iss=#{iss}"
end

get "/callback" do
  # /tokenからjsonを取得する
  uri = URI.parse(BASE_URL + "/token")
  res = Net::HTTP.post_form(uri, { code: params[:code] })
  json = JSON.parse(res.body)
  id_token = json["id_token"]
  erb :callback, locals: { id_token: id_token }
end

post "/token" do
  code = params[:code]
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
    iss: "https://example.com",
    aud: "client_id",
    exp: Time.now.to_i + 360,
  }
  JWT.encode(payload, nil, "HS256")
end
