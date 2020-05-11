#!/bin/bash
set +x

# Build docker image using the local Dockerfile
docker build -t logstash-codec-kafka-time-machine .