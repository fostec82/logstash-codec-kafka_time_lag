Gem::Specification.new do |s|
    s.name = 'logstash-output-kafka_time_lag'
    s.version = '0.1.0'
    s.licenses = ['Apache License (2.0)']
    s.summary = "Parse a string of influx line protocol to fields"
    s.description = "This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install gemname. This gem is not a stand-alone program"
    s.authors = ["Chris Foster"]
    s.email = 'chris.foster78@gmail.com'
    # s.homepage = "http://www.elastic.co/guide/en/logstash/current/index.html"
    s.require_paths = ["lib"]

    # Files
    s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
     # Tests
    s.test_files = s.files.grep(%r{^(test|spec|features)/})

    # Special flag to let us know this is actually a logstash plugin
    s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

    # Gem dependencies
    s.add_runtime_dependency "logstash-core-plugin-api", ">= 1.60", "<= 2.99"
    s.add_development_dependency 'logstash-devutils'
  end