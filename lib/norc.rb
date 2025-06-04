# frozen_string_literal: true

require "redis"
require "json"
require "time"
require "logger"
require_relative "norc/config"
require_relative "norc/scheduler"
require_relative "norc/version"

module Norc
  class Error < StandardError; end
  include Config
  extend Scheduler
end
