namespace :deploy do
  desc "update the database with seed data"
  task :seed, :roles => :db do
    run "cd #{current_path} && bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end
end
