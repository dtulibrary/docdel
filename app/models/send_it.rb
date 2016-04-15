require 'httparty'

class SendIt

  def self.local_scan_request order, params = {}
    params['order'] = order.as_json
    send_mail 'docdel_scan_request', params
  end

  private

  def self.send_mail template, params = {}
    begin
      url = "#{config.sendit_url}/send/#{template}"

      default_params = {
        :from => 'noreply@dtic.dtu.dk',
        :priority => 'now'
      }

      response = HTTParty.post url, {
        :body => default_params.deep_merge(params).to_json,
        :headers => { 'Content-Type' => 'application/json' }
      }

      unless response.code == 200
        logger.error "SendIt responded with HTTP #{response.code}"
        raise "Error communicating with SendIt"
      end
    rescue
      logger.error "Error sending mail: template = #{template}\n#{params}"
      raise
    end
  end

  def self.config
    Rails.application.config
  end

  def self.logger
    Rails.logger
  end

end

