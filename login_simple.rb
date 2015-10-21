# login_simple.rb
# Template for setting up a basic rails app with a minimal login system and my
# favourite gems
# Login logic inspired by: https://gist.github.com/thebucknerlife/10090014

generate(:model, "User email:string name:string password_digest:string")
generate(:scaffold_controller, "User email name password password_confirmation")
generate(:controller, "sessions new create destroy --skip")

route "root to: 'users#index'"
route 'resources :users'
route "get '/login' => 'sessions#new'"
route "post '/login' => 'sessions#create'"
route "get '/logout' => 'sessions#destroy'"
route "get '/signup' => 'users#new'"
route "post '/users' => 'users#create'"

rake("db:migrate")

gem 'bcrypt', '~> 3.1.7'
gem 'haml-rails'
gem_group :development do
  gem 'better_errors'
end

session_create =
'    user = User.find_by_email(params[:email])
    # If the user exists AND the password entered is correct.
    if user && user.authenticate(params[:password])
      # Save the user id inside the browser cookie. This is how we keep the user
      # logged in when they navigate around our website.
      session[:user_id] = user.id
      redirect_to \'/\'
    else
    # If user\'s login doesn\'t work, send them back to the login form.
      redirect_to \'/login\'
    end
'
session_new =
'    session[:user_id] = nil
'
application_controller_actions =
'  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def authorize
    redirect_to \'/login\' unless current_user
  end
'

insert_into_file 'app/controllers/sessions_controller.rb', session_create,
                  after: "def create\n"
insert_into_file 'app/controllers/sessions_controller.rb', session_new,
                  after: "def new\n"
insert_into_file 'app/controllers/application_controller.rb',
                  application_controller_actions,
                  after: "protect_from_forgery with: :exception\n"

insert_into_file 'app/models/user.rb', "has_secure_password\n",
                  after: "class User < ActiveRecord::Base\n"
insert_into_file 'app/controllers/users_controller.rb',
                  "  before_filter :authorize, except: [:new]\n",
                  after: "class UsersController < ApplicationController\n"

line = '<%= f.text_field :password %>'
gsub_file 'app/views/users/_form.html.erb', /(#{Regexp.escape(line)})/mi do |match|
  '<%= f.password_field :password %>'
end

line = '<p>Find me in app/views/sessions/new.html.erb</p>'
new_html =
'<%= form_tag \'/login\' do %>
  <div class="field">
    <%= label_tag :email %><br>
    <%= text_field_tag :email %>
  </div>
  <div class="field">
    <%= label_tag :password %><br>
    <%= password_field_tag :password %>
  </div>
  <%= submit_tag "Sign in" %>
<% end %>
<p>Not registered?
<%= link_to "Sign up", signup_path %>
now!
'
gsub_file 'app/views/sessions/new.html.erb', /(#{Regexp.escape(line)})/mi do |match|
  new_html
end

line = '<h1>Sessions#new</h1>'
gsub_file 'app/views/sessions/new.html.erb', /(#{Regexp.escape(line)})/mi do |match|
  '<h1>Login</h1>'
end

after_bundle do
  rake('haml:erb2haml')
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
