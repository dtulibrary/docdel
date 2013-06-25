# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Haitatsu::Application.initialize!

Haitatsu::Application.configure do
  config.colorize_logging = false
end

