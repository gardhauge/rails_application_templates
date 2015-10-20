# login_simple.rb
# Template for setting up a basic rails app with a minimal login system and my
# favourite gems

generate(:model, "User email:string name:string password_digest:string")
generate(:scaffold_controller, "User email name")

route "root to: 'users#index'"
route 'resources :users'
rake("db:migrate")

gem 'bcrypt', '~> 3.1.7'
gem 'haml-rails'
gem_group :development do
  gem 'better_errors'
end

insert_into_file 'app/models/user.rb', "has_secure_password\n",
                 after: "class User < ActiveRecord::Base\n"

after_bundle do
  rake('haml:erb2haml')
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
