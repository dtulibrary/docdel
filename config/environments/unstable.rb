Haitatsu::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the unstable environment your application's code is cached 
  config.cache_classes = true

  # Configure static asset server for unstable with Cache-Control for performance
  config.serve_static_assets = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and enable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # See everything in the log (default is :info)
  config.log_level = :debug

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
end
