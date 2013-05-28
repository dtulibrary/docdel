# Extend the configuration options
Haitatsu::Application.configure do
  config.class.class_eval do
    def reprintsdesk
      @reprintsdesk ||= ActiveSupport::OrderedOptions.new
    end
  end
end

