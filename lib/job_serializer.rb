require 'yaml'

module Workerholic
  class JobSerializer
    def self.serialize(job)
      YAML.dump(job)
    end

    def self.deserialize(yaml_job)
      YAML.load(yaml_job)
    end
  end
end
