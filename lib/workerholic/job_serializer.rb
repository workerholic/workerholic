module Workerholic
  class JobSerializer
    def self.serialize(job)
      YAML.dump(job.to_hash)
    end

    def self.deserialize(yaml_job)
      job_info = YAML.load(yaml_job)
      JobWrapper.new(job_info)
    end

    def self.serialize_stats(stat)
      YAML.dump(stat)
    end

    def self.deserialize_stats(yaml_stat)
      YAML.load(yaml_stat)
    end
  end
end
