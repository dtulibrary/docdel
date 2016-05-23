if Docdel::Application.config.respond_to? :reprintsdesk
  require "suppliers/reprintsdesk"
end

if Docdel::Application.config.respond_to? :local_scan
  require "suppliers/local_scan"
  if Rails.env.staging?
    require "suppliers/local_clean"
  end
end

if Docdel::Application.config.respond_to? :tib
  require "suppliers/tib"
end
