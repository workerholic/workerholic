module Workerholic

  class Job

    def initialize(klass, args)
      @klass = klass
      @args = args
      @storage = Storage::RedisWrapper.new
    end

    def serialized
      job_obj = [@klass, @args]
      ::YAML.dump(job_obj)
    end

    def push(queue_name = 'default')
      @storage.push(queue_name, serialized)
    end

  end

end
