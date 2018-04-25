require "herokuci/version"
require 'rubygems'
require 'json'
require 'blink1'
require 'optparse'

module Herokuci
  def self.get_heroku_ci_status_of_latest_build(application)
    ci_results = `heroku ci -j -w -a #{application}`
    parsed_results = JSON.parse(ci_results)
    parsed_results[0]["status"]
  end

  def self.reflect_state_via_build_light(latest_build_state)
    puts "CI status: #{latest_build_state}"
    blink1 = Blink1.new
    blink1.open
    blink1.set_rgb(0, 255, 0) if latest_build_state == "succeeded"
    blink1.set_rgb(255, 0, 0) unless latest_build_state == "succeeded"
    blink1.close
  end

  def self.update_build_light_state(application)
    latest_build_state = get_heroku_ci_status_of_latest_build(application)
    reflect_state_via_build_light(latest_build_state)
  end


  def self.every_n_seconds(n)
    loop do
      before = Time.now
      yield
      interval = n-(Time.now-before)
      sleep(interval) if interval > 0
    end
  end

  options = {}
  option_parser = OptionParser.new do|opts|
    opts.banner = "Usage: herokuci [options] applicationName"
    opts.on('-a', '--application APPLICATION', "Require the application for polling") do |application|
      options[:application] = application
    end
    options[:poll] = 300
    opts.on('--poll N', Integer, "Poll frequency N seconds") do |n|
      options[:poll] = n
    end

    opts.on_tail('-h', '--help', "Show this message") do
      puts opts
      exit
    end

    opts.on_tail('--version', "Show version") do
      puts VERSION
      exit
    end
  end
  option_parser.parse!

  raise OptionParser::MissingArgument if options[:application].nil?

  every_n_seconds(options[:poll]) do
    update_build_light_state(options[:application])
  end
end
