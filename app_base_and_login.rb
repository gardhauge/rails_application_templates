# app_base_and_login.rb
# Template for setting up a basic rails app with a minimal login system and my
# favourite gems
# Login logic inspired by: https://gist.github.com/thebucknerlife/10090014

generate(:migration, 'create_users', 'email:string name:string password_digest:string')

route "root to: 'users#index'"
route 'resources :users'
route "get '/login' => 'sessions#new'"
route "post '/login' => 'sessions#create'"
route "get '/logout' => 'sessions#destroy'"
route "get '/signup' => 'users#new'"
route "post '/users' => 'users#create'"

rake("db:migrate")

gem 'bcrypt', '~> 3.1.7'
use_haml = yes?("Want to use haml for templates?")
gem 'haml-rails' if use_haml
gem_group :development do
  gem 'better_errors'
end
gem 'foundation-rails'

# For unknown reasons, replacing application_controller.rb doesn't
# work, so I have to edit the file instead.
application_controller_actions =
'  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def authorize
    redirect_to \'/login\' unless current_user
  end
'

insert_into_file 'app/controllers/application_controller.rb',
                  application_controller_actions,
                  after: "protect_from_forgery with: :exception\n"

def source_paths
  Array(super) +
    [File.join(File.expand_path(File.dirname(__FILE__)),'rails_root')]
end
inside 'app' do
  inside 'models' do
    copy_file 'user.rb'
  end
  inside 'controllers' do
    copy_file 'sessions_controller.rb'
    copy_file 'users_controller.rb'
  end
  inside 'views' do
    inside 'users' do
      copy_file '_form.html.erb'
      copy_file 'edit.html.erb'
      copy_file 'index.html.erb'
      copy_file 'new.html.erb'
      copy_file 'show.html.erb'
    end
    inside 'sessions' do
      copy_file 'new.html.erb'
    end
  end
end

after_bundle do
  rake('haml:erb2haml') if use_haml
  generate('foundation:install', '--force', '--quiet') unless use_haml
  generate('foundation:install', '--haml', '--force', '--quiet') if use_haml

  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
