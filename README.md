# Norc

Cron Job Scheduler with Redis Persistence

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add norc
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install norc
```

## Usage

```ruby
require "norc"

Norc.configure do |config|
  config.redis_url = "redis://localhost:6379"
end

Norc.start
```

This implementation provides a complete cron job scheduler with Redis persistence featuring:

# Key Features:

- Job Management: Add, remove, enable/disable jobs with unique IDs
- Redis Persistence: All job data persists across application restarts
- Cron Expression Support: Basic cron syntax parsing (minute, hour, day, month, weekday)
- Execution History: Tracks job execution history with timestamps and success status
- Thread-Safe Execution: Runs in background thread, checking jobs every minute
- Logging: Built-in logging for job execution and scheduler events

# Cron Expression Format:

- * * * * * = minute hour day month weekday
- Supports: wildcards (*), specific values (5), comma-separated lists (1,3,5)
- Example: 0 2 * * * runs daily at 2:00 AM

# Dependencies:

- logger
- redis
- Standard Ruby libraries (json, time, logger)

This scheduler is production-ready for basic use cases and can be extended with more sophisticated cron parsing, job priorities, or distributed execution capabilities.
