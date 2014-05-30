#!/usr/bin/ruby1.9.1 -rubygems
# mqtts.rb - Text to speech from certain MQTT topic
# alarmschaben - 2014-05-30

require 'mqtt'
require 'espeak'

include ESpeak

$topicprefix = '/nest/kitchen/tts'
keepgoing = true

mqtt = MQTT::Client.connect('localhost')
mqtt.subscribe($topicprefix + '/#')

def process_message(topic, message)
  if topic.index($topicprefix) == 0
    speech = Speech.new(message, voice: "mb-de7", speed: 118)
    speech.speak
  end
end

Signal.trap("TERM") do
  keepgoing = false
end

Signal.trap("INT") do
  keepgoing = false
end

while keepgoing
  if ! mqtt.queue_empty?
    topic, message = mqtt.get
    process_message(topic, message)
  else
    sleep 1
  end
end

mqtt.disconnect

