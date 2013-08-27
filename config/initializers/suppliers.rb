if Haitatsu::Application.config.respond_to? :reprintsdesk
  puts "Include reprints desk"
  require "suppliers/reprintsdesk"
end

if Haitatsu::Application.config.respond_to? :local_scan
  puts "Include local scan"
  require "suppliers/local_scan"
end
