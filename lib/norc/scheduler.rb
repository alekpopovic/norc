# frozen_string_literal: true

require_relative "cron"

module Norc
  module Scheduler
    extend self
    include Config
    include Cron

    REDIS_KEY_PREFIX = "norc_scheduler"
    JOBS_KEY = "#{REDIS_KEY_PREFIX}:jobs"
    HISTORY_KEY = "#{REDIS_KEY_PREFIX}:history"

    def add(id:, name:, cron_expression:, command:, enabled: true)
      job = Executor.new(
        id: id,
        name: name,
        cron_expression: cron_expression,
        command: command,
        enabled: enabled,
      )

      redis.hset(JOBS_KEY, job.id, job.to_hash.to_json)
      logger.info("Added job: #{job.name} (#{job.id})")
      job
    end

    def remove(job_id)
      redis.hdel(JOBS_KEY, job_id)
      logger.info("Removed job: #{job_id}")
    end

    def get(job_id)
      job_data = redis.hget(JOBS_KEY, job_id)
      return unless job_data

      Executor.from_hash(JSON.parse(job_data))
    end

    def list
      jobs_data = redis.hgetall(JOBS_KEY)
      jobs_data.map { |id, data| Executor.from_hash(JSON.parse(data)) }
    end

    def enable(job_id)
      update_job_status(job_id, true)
    end

    def disable(job_id)
      update_job_status(job_id, false)
    end

    def start
      @running = true
      logger.info("Cron scheduler started")

      Thread.new do
        while running
          check_and_execute_jobs
          sleep(60)
        end
      end
    end

    def stop
      @running = false
      @logger.info("Cron scheduler stopped")
    end

    def running?
      @running
    end

    private

    def running
      @running = false
    end

    def redis
      Redis.new(url: config.redis_url)
    end

    def logger
      Logger.new(STDOUT)
    end

    def check_and_execute_jobs
      jobs = list_jobs
      due_jobs = jobs.select(&:due?)

      due_jobs.each do |job|
        logger.info("Executing job: #{job.name}")

        start_time = Time.now
        success = job.execute!
        end_time = Time.now

        redis.hset(JOBS_KEY, job.id, job.to_hash.to_json)

        log_execution(job, start_time, end_time, success)
      end
    end

    def update_job_status(job_id, enabled)
      job = get_job(job_id)
      return false unless job

      job.enabled = enabled
      redis.hset(JOBS_KEY, job_id, job.to_hash.to_json)
      logger.info("Job #{job_id} #{enabled ? "enabled" : "disabled"}")
      true
    end

    def log_execution(job, start_time, end_time, success)
      history_entry = {
        job_id: job.id,
        job_name: job.name,
        start_time: start_time.iso8601,
        end_time: end_time.iso8601,
        duration: end_time - start_time,
        success: success,
        timestamp: Time.now.iso8601,
      }

      redis.lpush(HISTORY_KEY, history_entry.to_json)
      redis.ltrim(HISTORY_KEY, 0, 999)
    end

    public

    def execution_history(limit: 50)
      history_data = redis.lrange(HISTORY_KEY, 0, limit - 1)
      history_data.map { |data| JSON.parse(data) }
    end
  end
end
