require 'sinatra'
require 'json'

set :public_folder, 'public'

get '/photos' do

  content_type :json

  Dir.chdir('public/photos/') do

    Dir.glob('*').to_json

  end

end

get '/' do

  erb :index

end