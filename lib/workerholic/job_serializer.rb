module Workerholic
  class JobSerializer
    def self.serialize(job)
      JSON.dump(job.to_hash)
    end

    def self.deserialize(json_job)
      job_info = JSON.parse(json_job, symbolize_names: true)

      job_info[:klass] = job_info[:klass] ? Object.const_get(job_info[:klass]) : nil
      job_info[:wrapper] = job_info[:wrapper] ? Object.const_get(job_info[:wrapper]) : nil

      JobWrapper.new(job_info)
    end

    def self.deserialize_stats(json_stat)
      JSON.parse(json_stat, symbolize_names: true)
    end
  end
end
