require 'sinatra'
require 'sinatra/reloader'

get '/' do
  erb :index
end

get '/details' do
  erb :details
end

get '/queues' do
  #placeholder
  erb :index
end

get '/workers' do
  #placeholder
  erb :workers
end

get '/failed' do
  #placeholder
  erb :index
end

get '/scheduled' do
  #placeholder
  erb :scheduled
end
