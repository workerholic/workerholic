module Workerholic
  class JobSerializer
    def self.serialize(job)
      YAML.dump(job.to_hash)
    end

    def self.deserialize(yaml_job)
      job_info = YAML.load(yaml_job)
      JobWrapper.new(job_info)
    end
  end
end
