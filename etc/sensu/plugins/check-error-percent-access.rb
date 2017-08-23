#!/usr/bin/env ruby
# author: Lokesh Ponnuswamy
# Calculte error percentage during a specific time interval


require 'date'
require 'time'
require 'sensu-plugin/check/cli'

class CheckErrorPercentage  < Sensu::Plugin::Check::CLI

  option :seconds,
          description:'time in seconds, to go back in the log file',
          short:'-s SECONDS',
          long: '--server SECONDS',
          proc: proc(&:to_i),
          default: 600

  option :log_time_zone,
          description: 'Enter timezone in log file',
          short: '-t LOG_TIME_ZONE',
          long: '--timezone LOG_TIME_ZONE',
          proc: proc(&:to_s),
          default: "UTC"

  option :logfile,
          description: 'Access log file path',
          short: '-p LOGFILEPATH',
          long: '--path LOGFILEPATH',
          required: true,
          proc: proc(&:to_s)

  option :warn,
          short: '-w PERCENT',
          description: 'Warn if PERCENT or more of disk full',
          proc: proc(&:to_i),
          default: 10

  option :crit,
          short: '-c PERCENT',
          description: 'Critical if PERCENT or more of disk full',
          proc: proc(&:to_i),
          default: 20

  def initialize
    super
    @crit_fs = []
    @warn_fs = []
  end

  def usage_summary
    (@crit_fs + @warn_fs).join(', ')
  end
  # Open the file and read the lines in reverse; exit once time stamps are beyond our time threshold

  def get_file_contents
    file = File.open(config[:logfile], "r")
    log_snapshot = file.readlines
    file.close
    log_snapshot
  end

  def parse_log_for_http_response
    log_snapshot = get_file_contents
    log_array = []
    start_time = Time.now.to_i
    log_snapshot.reverse_each do |line|
      one_line_array = line.split("\"")
      date_container = one_line_array[0].to_s.split(" ")
      http_response_container = one_line_array[2].to_s.split(" ")
      date_time = date_container[3][1..date_container[3].length-1]
      date_time[11] = " "
      date_time = Time.iso8601(DateTime.parse(date_time+" "+config[:log_time_zone]).to_s).to_i
      if date_time > (start_time - config[:seconds].to_i)
        log_array << [http_response_container[0], date_time]
      else
        break
      end
    end
    log_array
  end

  def run
    log_array = parse_log_for_http_response
    errors = 0
    success = 0
    errorpercent = 0

    log_array.each do |i|
      if i[0].to_i > 299
        errors+=1
      else
        success+=1
      end
    end

    if (log_array.length) != 0
      errorpercent = 100 * errors / ( log_array.length )
      if (errorpercent).to_i >= config[:crit]
        @crit_fs << "Error percent in the last #{config[:seconds]} seconds: #{errorpercent}%, Total Hits: #{log_array.length}"
      elsif (errorpercent).to_i >= config[:warn]
        @warn_fs << "Error percent in the last #{config[:seconds]} seconds: #{errorpercent}%, Total Hits: #{log_array.length}"
      end
    end

    critical usage_summary unless @crit_fs.empty?
    warning usage_summary unless @warn_fs.empty?
    ok "Error percent in the last #{config[:seconds]} seconds: #{errorpercent}%, Total hits: #{log_array.length}"
  end
end
