require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'redis'
require 'koala'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

redis = Redis.new

get '/' do

  erb :index

end

get '/barcode' do

  content_type :png

  barcode = Barby::Code128B.new(params[:content])

  barcode.to_png

end

post '/users/auth' do

  content_type :json

  access_token = params[:access_token]

  halt 400 unless access_token

  profile = Koala::Facebook::API.new(access_token).get_object('me')

  redis.set("user_#{profile['id']}", {:profile => profile, :access_token => access_token}.to_json)

  profile.to_json

end

post '/users/current' do

  content_type :json

  user = redis.get("user_#{params[:id]}")

  halt 404 unless user

  redis.set('current_user', user)

  FileUtils.rm_rf(Dir.glob('public/photos/*'))

  user

end

post '/users/share' do

  content_type :json

  image = params[:image]

  halt 400 unless image

  user = JSON.parse(redis.get('current_user'))

  Koala::Facebook::API.new(user['access_token']).put_picture("public/photos/#{image}")

  'OK'.to_json

end

get '/stream' do

  current_user = JSON.parse(redis.get('current_user'))

  erb :stream, :locals => {:current_user => current_user}

end

get '/stream/photos' do

  content_type :json

  Dir.chdir('public/photos/') do

    Dir.glob('*').to_json

  end

end