# encoding: utf-8
require "logstash/codecs/base"
require "logstash/namespace"
require "logstash/event"

class LogStash::Codecs::KafkaTimeMachine < LogStash::Codecs::Base

  config_name "kafkatimemachine"

  @write_end_of_log = true

  # Enable debug log file writes
  config :enable_log, :validate => :boolean, :default => false

  def file_output( output_line )
    
    # Limit max file size to 5MB to protect integrity of host
    max_file_size = 5242880

    # Open file and append until max size reached
    File.open("/tmp/kafkatimemachine.txt", "a") do |f|
      if (f.size <= max_file_size)
        f.puts(output_line)
        @write_end_of_log = true
      elsif (f.size > max_file_size && @write_end_of_log == true)
        f.puts("Maximum file size of #{max_file_size} bytes reached; delete /tmp/kafkatimemachine.txt to resume writing")
        @write_end_of_log = false
      end
    end

  end

  public
  def register
  
  end

  public
  def decode(data)
    raise "Not implemented"
  end # def decode

  public
  def encode(event)

    # Extract producer data and check for validity
    kafka_datacenter_producer = event.get("[@metadata][kafka_datacenter_producer]")
    kafka_topic_producer = event.get("[@metadata][kafka_topic_producer]")
    kafka_consumer_group_producer = event.get("[@metadata][kafka_consumer_group_producer]")
    kafka_append_time_producer = Integer(event.get("[@metadata][kafka_append_time_producer]")) rescue nil 
    logstash_kafka_read_time_producer = Integer(event.get("[@metadata][logstash_kafka_read_time_producer]")) rescue nil

    kafka_producer_array = Array[kafka_datacenter_producer, kafka_topic_producer, kafka_consumer_group_producer, kafka_append_time_producer, logstash_kafka_read_time_producer]
    @logger.debug("kafka_producer_array: #{kafka_producer_array}")

    if (kafka_producer_array.any? { |text| text.nil? || text.to_s.empty? })
      @logger.debug("kafka_producer_array invalid: Found null")
      error_string_producer = "Error in producer data: #{kafka_producer_array}"
      producer_valid = false
    else
      @logger.debug("kafka_producer_array valid")
      producer_valid = true
      kafka_producer_lag_ms = logstash_kafka_read_time_producer - kafka_append_time_producer
    end

    # Extract aggregate data and check for validity
    kafka_datacenter_aggregate = event.get("[@metadata][kafka_datacenter_aggregate]")
    kafka_topic_aggregate = event.get("[@metadata][kafka_topic_aggregate]")
    kafka_consumer_group_aggregate = event.get("[@metadata][kafka_consumer_group_aggregate]")
    kafka_append_time_aggregate = Integer(event.get("[@metadata][kafka_append_time_aggregate]")) rescue nil
    logstash_kafka_read_time_aggregate = Integer(event.get("[@metadata][logstash_kafka_read_time_aggregate]")) rescue nil

    kafka_aggregate_array = Array[kafka_datacenter_aggregate, kafka_topic_aggregate, kafka_consumer_group_aggregate, kafka_append_time_aggregate, logstash_kafka_read_time_aggregate]
    @logger.debug("kafka_aggregate_array: #{kafka_aggregate_array}")

    if (kafka_aggregate_array.any? { |text| text.nil? || text.to_s.empty? })
      @logger.debug("kafka_aggregate_array invalid: Found null")
      error_string_aggregate = "Error in aggregate data: #{kafka_aggregate_array}"
      aggregate_valid = false
    else
      @logger.debug("kafka_aggregate_array valid")
      aggregate_valid = true
      kafka_aggregate_lag_ms = logstash_kafka_read_time_aggregate - kafka_append_time_aggregate
    end

    # Get current time for influxdb timestamp
    kafka_logstash_influx_metric_time = (Time.now.to_f * (1000*1000*1000)).to_i

    if (producer_valid == true && aggregate_valid == true)
      kafka_total_lag_ms = logstash_kafka_read_time_aggregate - kafka_append_time_producer
      influx_line_protocol = "kafka_lag_time,meta_source=lma,meta_type=ktm,meta_datacenter=#{kafka_datacenter_producer},ktm_lag_type=complete,kafka_topic_aggregate=#{kafka_topic_aggregate},kafka_consumer_group_aggregate=#{kafka_consumer_group_aggregate},kafka_topic_producer=#{kafka_topic_producer},kafka_consumer_group_producer=#{kafka_consumer_group_producer} kafka_total_lag_ms=#{kafka_total_lag_ms},kafka_aggregate_lag_ms=#{kafka_aggregate_lag_ms},kafka_producer_lag_ms=#{kafka_producer_lag_ms} #{kafka_logstash_influx_metric_time}"
    elsif (producer_valid == true && aggregate_valid == false)
      influx_line_protocol = "kafka_lag_time,meta_source=lma,meta_type=ktm,meta_datacenter=#{kafka_datacenter_producer},ktm_lag_type=producer,kafka_topic_producer=#{kafka_topic_producer},kafka_consumer_group_producer=#{kafka_consumer_group_producer} kafka_producer_lag_ms=#{kafka_producer_lag_ms} #{kafka_logstash_influx_metric_time}"
    elsif (aggregate_valid == true && producer_valid == false)
      influx_line_protocol = "kafka_lag_time,meta_source=lma,meta_type=ktm,meta_datacenter=#{kafka_datacenter_aggregate},ktm_lag_type=aggregate,kafka_topic_aggregate=#{kafka_topic_aggregate},kafka_consumer_group_aggregate=#{kafka_consumer_group_aggregate} kafka_aggregate_lag_ms=#{kafka_aggregate_lag_ms} #{kafka_logstash_influx_metric_time}"
    elsif (aggregate_valid == false && producer_valid == false)
      @logger.error("Error kafkatimemachine: Could not build valid response --> #{error_string_producer}, #{error_string_aggregate}")
      influx_line_protocol = nil
    end

    if (!influx_line_protocol.nil? && @enable_log == true)
      file_output(influx_line_protocol)
    end

    @on_event.call(event, event.sprintf(influx_line_protocol))

  end # def encode

end # class LogStash::Codecs::KafkaTimeMachine