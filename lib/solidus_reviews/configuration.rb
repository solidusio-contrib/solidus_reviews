# frozen_string_literal: true

module SolidusReviews
  class Configuration
    # Define here the settings for this extension, e.g.:
    #
    # attr_accessor :my_setting
    attr_accessor :report_reasons

    def initialize
      # Set default report reasons
      @report_reasons = ['offensive-content', 'spam', 'inappropriate-language']
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias config configuration

    def configure
      yield configuration
    end
  end
end
