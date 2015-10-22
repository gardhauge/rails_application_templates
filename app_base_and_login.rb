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
    copy_file 'application_controller.rb'
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
      copy_file 'destroy.html.erb'
    end
  end
end

gem 'bcrypt', '~> 3.1.7'
use_haml = yes?("Want to use haml for templates?")
gem 'haml-rails' if use_haml
gem_group :development do
  gem 'better_errors'
end

after_bundle do
  rake('haml:erb2haml') if use_haml
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
