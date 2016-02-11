source 'https://rubygems.org'

gem 'rails', '~> 3.2.0'
gem 'jquery-rails', '~> 2.3.0'
gem 'activeadmin'
gem 'devise_cas_authenticatable'
gem 'openurl'
gem 'savon'
gem 'httparty'
gem 'capistrano', '~> 2.15'
gem 'incoming_mail', :git => 'https://github.com/dtulibrary/incoming_mail'
gem 'bootstrap-sass', '~> 3.1.1'

# Gems used only for assets.
gem 'sass-rails',   '~> 3.2'
gem 'coffee-rails', '~> 3.2.1'
gem 'therubyracer', :platforms => :ruby
gem 'turbo-sprockets-rails3'
gem 'uglifier', '>= 1.0.3'
gem 'findit_font', :git => 'git://github.com/dtulibrary/findit_font.git'

group :development do
  gem 'rails_best_practices'
end

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'brakeman'
  gem 'byebug'
end

group :test do
  gem 'simplecov', :require => false
  gem 'simplecov-html', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'mocha', :require => false
  gem 'factory_girl_rails'
  gem 'webmock'
end

group :production do
  gem 'pg'
end
