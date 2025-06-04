# frozen_string_literal: true

module Norc
  module Config
    class << self
      def included(base)
        base.extend(ClassMethods)
      end
    end
    module ClassMethods
      def config
        @config ||= Configuration.new
      end

      def configure
        yield config
      end
    end

    class Configuration
      attr_accessor :redis_url
    end
  end
end
