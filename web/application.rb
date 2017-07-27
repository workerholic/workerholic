require 'sinatra'
require 'sinatra/reloader'

get '/' do
  redirect '/overview'
end

get '/overview' do
  erb :index
end

get '/details' do
  erb :details
end

get '/queues' do
  erb :queues
end

get '/workers' do
  erb :workers
end

get '/failed' do
  erb :failed
end

get '/scheduled' do
  erb :scheduled
end
