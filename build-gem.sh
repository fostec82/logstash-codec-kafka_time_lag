#!/bin/bash
set +x

# Remove old gems
rm -f *.gem
rm -f unit-test/*.gem

# Build gem and copy to unit-test
gem build logstash-codec-kafka_time_machine.gemspec

cp *.gem unit-test/.