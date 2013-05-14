source 'https://rubygems.org'

gem 'rails'
gem 'jquery-rails'
gem 'activeadmin'
gem 'devise_cas_authenticatable'

# Gems used only for assets.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'rails_best_practices'
end

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'brakeman'
  gem 'debugger'
end

group :test do
  gem 'simplecov', :require => false
  gem 'simplecov-html', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'mocha', :require => false
  gem 'factory_girl_rails'
end

group :production do
  gem 'pg'
end

