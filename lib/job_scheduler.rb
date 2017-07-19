require_relative 'sorted_set'

module Workerholic
  class JobScheduler
    def initialize(set_name = 'workerholic:scheduled_jobs')
      @sorted_set = SortedSet.new(set_name)
    end

    def schedule(serialized_job)
    end
  end
end
