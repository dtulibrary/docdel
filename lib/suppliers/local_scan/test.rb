require 'httparty'

# Extend the configuration options
Haitatsu::Application.configure do
  config.class.class_eval do
    def local_scan
      @local_scan ||= ActiveSupport::OrderedOptions.new
    end
  end
end

class Order < ActiveRecord::Base

  def request_from_local_scan
    logger.info "Execute LocalScan"
    # Send email to scanning team
    url = config.local_scan.sendit_server
    # Gather data for mail
    data = ""
    self.accessible_attributes.each do |attr|
      data << attr +"="+self.send(attr).uri_escape
    end
    response = HTTParty.post(url, data)
    raise "Couldn't send mail for Local Scan" unless (response.success?)
  end
end
