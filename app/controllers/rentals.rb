require 'bcrypt'
require 'sinatra/flash'

class App < Sinatra::Base

  register Sinatra::Flash

  get '/' do
    erb(:index)
  end

  get '/users/new' do
    erb(:user)
  end

  post '/users/new' do
    user = User.new(email: params[:email], password: params[:password], password_confirmation: params[:password_confirmation])
      if user.save
        session[:user_id] = user.id
        redirect '/'
      else
        redirect '/users/new'
      end
  end

  get '/users/signin' do
    erb(:signin)
  end

  post '/users/signin' do
    current_user = User.first(email: params[:email])
      if current_user && BCrypt::Password.new(current_user.hashed_password) == params[:password]
        session[:user_id] = current_user.id
        redirect '/'
      else
        flash.now[:notice] = "Password or email not correct"
        erb(:signin)
      end
    end

  get '/rentals/view' do
    erb(:property)
  end

  get '/rentals/create'do
    erb(:create)
  end

  post '/rentals/create' do
    Rental.create(price: params[:price], address: params[:address], image: params[:image])
    redirect('/')
  end

  get '/rentals/:id' do |id|
    content_type :json
    return 404 if Rental.get(id).nil?
    rental_to_json(id)
  end

  get '/rentals' do
    content_type :json
    rentals_to_json
  end

  get '/bookings' do
    content_type :json
    bookings_to_json
  end

  get '/bookings/validate/:id' do |id|
    content_type :json
    return 404 if Rental.get(id).nil?
    start, finish = parse_dates(params)
    { available: available?(id, start, finish) }.to_json
  end


  post '/bookings/:id' do |id|
    start, finish = parse_dates(params)
    book(id, start, finish)
  end
end
