module Workerholic
  class SortedSet
    attr_reader :storage, :name

    def initialize(name = 'workerholic:scheduled_jobs')
      @storage = Storage::RedisWrapper.new
      @name = name
    end

    def add(serialized_job, score)
      storage.add_to_set(name, score, serialized_job)
    end

    def remove(score)
      storage.remove_from_set(name, score)
    end

    def peek
      storage.peek(name)
    end

    def empty?
      storage.set_empty?(name) == 0
    end
  end
end
