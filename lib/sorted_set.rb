require_relative 'storage'

module Workerholic
  class SortedSet
    attr_reader :storage, :name

    def initialize(name = 'workerholic:scheduled_jobs')
      @storage = Storage::RedisWrapper.new
      @name = name
    end

    def add(serialized_job)
      storage.add_to_set(name, serialized_job)
    end

    def remove
      storage.remove_from_set(name)
    end

    def peek
      storage.peek_set(name)
    end
  end
end
