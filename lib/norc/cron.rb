# frozen_string_literal: true

module Norc
  module Cron
    class Executor
      attr_accessor :id, :name, :cron_expression, :command, :enabled, :last_run, :next_run, :created_at

      def initialize(id:, name:, cron_expression:, command:, enabled: true)
        @id = id
        @name = name
        @cron_expression = cron_expression
        @command = command
        @enabled = enabled
        @last_run = nil
        @next_run = calculate_next_run
        @created_at = Time.now
      end

      def to_hash
        {
          id: @id,
          name: @name,
          cron_expression: @cron_expression,
          command: @command,
          enabled: @enabled,
          last_run: @last_run&.iso8601,
          next_run: @next_run&.iso8601,
          created_at: @created_at.iso8601,
        }
      end

      def self.from_hash(hash)
        job = new(
          id: hash["id"],
          name: hash["name"],
          cron_expression: hash["cron_expression"],
          command: hash["command"],
          enabled: hash["enabled"],
        )
        job.last_run = Time.parse(hash["last_run"]) if hash["last_run"]
        job.next_run = Time.parse(hash["next_run"]) if hash["next_run"]
        job.created_at = Time.parse(hash["created_at"]) if hash["created_at"]
        job
      end

      def due?
        @enabled && @next_run && Time.now >= @next_run
      end

      def execute!
        return false unless @enabled

        begin
          result = system(@command)
          @last_run = Time.now
          @next_run = calculate_next_run
          result
        rescue StandardError => e
          puts "Error executing job #{@name}: #{e.message}"
          false
        end
      end

      private

      def calculate_next_run
        parts = @cron_expression.split(" ")
        return if parts.length != 5

        now = Time.now
        minute, hour, day, month, weekday = parts

        next_time = now + 60

        1000.times do |i|
          return next_time if matches_cron_expression?(next_time, minute, hour, day, month, weekday)

          next_time += 60
        end

        nil
      end

      def matches_cron_expression?(time, minute, hour, day, month, weekday)
        return false unless matches_field?(time.min, minute)
        return false unless matches_field?(time.hour, hour)
        return false unless matches_field?(time.day, day)
        return false unless matches_field?(time.month, month)
        return false unless matches_field?(time.wday, weekday)

        true
      end

      def matches_field?(value, pattern)
        return true if pattern == "*"
        return value == pattern.to_i if pattern.match?(/^\d+$/)
        return pattern.split(",").map(&:to_i).include?(value) if pattern.include?(",")
        return (value % pattern.split("/").last.to_i == 0) if pattern.include?("/")

        false
      end
    end
  end
end
