require 'httparty'

class Riyosha
  def self.find(identifier)
    JSON.parse(HTTParty.get(config.user_url + "/users/#{identifier}.json").body)
  end

  def self.config
    Rails.application.config
  end

end
