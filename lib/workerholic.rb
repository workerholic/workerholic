require 'json'
require 'redis'
require 'connection_pool'
require 'logger'

require 'workerholic/starter'
require 'workerholic/manager'
require 'workerholic/worker_balancer'

require 'workerholic/job'
require 'workerholic/job_wrapper'

require 'workerholic/worker'
require 'workerholic/job_processor'
require 'workerholic/job_scheduler'
require 'workerholic/job_retry'

require 'workerholic/storage'
require 'workerholic/sorted_set'
require 'workerholic/queue'
require 'workerholic/statistics_storage'

require 'workerholic/job_serializer'
require 'workerholic/job_statistics'
require 'workerholic/log_manager'

require 'workerholic/statistics_api'
require 'workerholic/statistics_storage'

require 'workerholic/adapters/active_job_adapter' if defined?(Rails)

module Workerholic
  PIDS = [Process.pid]
  REDIS_URL = ENV['REDIS_URL'] || 'redis://localhost:' + ($TESTING ? '1234' : '6379')

  def self.workers_count
    @workers_count || 25
  end

  def self.workers_count=(num)
    raise ArgumentError unless num.is_a?(Integer) && num < 200
    @workers_count = num
  end

  def self.redis_connections_count
    @redis_connections_count || (workers_count + 3)
  end

  def self.redis_connections_count=(num)
    raise ArgumentError unless num.is_a?(Integer) && num < 200
    @redis_connections_count = num
  end

  def self.redis_pool
    @redis ||= ConnectionPool.new(size: redis_connections_count, timeout: 5) do
      Redis.new(url: REDIS_URL)
    end
  end

  def self.manager=(mgr)
    @manager = mgr
  end

  def self.manager
    @manager
  end
end
