#!/usr/bin/env ruby
# check_sftp.rb - download a file via sftp and compare its contents with a checkstring
# 2012-03-07 AGn

require 'rubygems'
require 'nagios-probe'
require 'net/sftp'

class Sftp_probe < Nagios::Probe

  @data = nil

  def measure
     Net::SFTP.start(@opts['host'], @opts['username'], :password => 'password') do |sftp|
      sftp.file.open(@opts['filename'], "r") do |f|
        @data = f.gets.chomp
      end
    end
  end

  def check_crit
    if @data.eql?(nil)
      true
    end
  end

  def check_warn
    if @data.eql?(@opts['checkstring'])
      false
    else
      true
    end
  end

  def crit_message
    "Connection to jailroot failed"
  end

  def warn_message
    "Test file content did not match"
  end

  def ok_message
    "Test file downloaded successfully"
  end
end

begin

  if ARGV.length != 4
    raise "Usage: #{$0} <host> <username> <filename with path> <checkstring>"
  end

  options = { 
    'host' => ARGV[0], 
    'username' => ARGV[1], 
    'filename' => ARGV[2],
    'checkstring' => ARGV[3]
  }

  probe = Sftp_probe.new(options)
  probe.measure
  probe.run
rescue Exception => e
  puts "Unknown: " + e
  exit Nagios::UNKNOWN
end

puts probe.message
exit probe.retval
