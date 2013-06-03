require 'httparty'

class StoreIt

  def self.store_pdf (pdf, mime_type, options = {})
    stored_url = nil
    begin
      options[:drm] ||= false
      url = "#{config.storeit_url}/rest/documents.text?drm=#{options[:drm]}"
      logger.info "Sending http request to StoreIt: URL = #{url}"
      response = HTTParty.post url, {
        :body => pdf,
        :headers => { 'Content-Type' => mime_type }
      }
      unless response.code == 200
        raise StandardError, "StoreIt responded with HTTP #{response.code}"
      end
      stored_url = response.body
      logger.info "Returned url #{stored_url}"
    rescue StandardError => e
      raise StandardError, "Error storing document #{e.message}"
    end
    stored_url
  end

  private

  def self.config
    Rails.application.config
  end

  def self.logger
    Rails.logger
  end

end

