# Extend the configuration options
Haitatsu::Application.configure do
  config.class.class_eval do
    def local_scan
      @local_scan ||= ActiveSupport::OrderedOptions.new
    end
  end
end
