['new', 'deliver', 'request', 'fail', 'cancel', 'confirm'].each do |code|
  unless OrderStatus.find_by_code(code)
    OrderStatus.create(code: code)
    puts "Seeded order status '#{code}'"
  end
end

['reprintsdesk', 'local_scan', 'tib'].each do |code|
  unless ExternalSystem.find_by_code(code)
    ExternalSystem.create(code: code)
    puts "Seeded external system '#{code}'"
  end
end

['not_avail'].each do |code|
  unless Reason.find_by_code(code)
    Reason.create(code: code)
    puts "Seeded reason '#{code}'"
  end
end
