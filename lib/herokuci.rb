require 'herokuci/version'
require 'herokuci/heroku_ci_api'
require 'herokuci/build_light'
require 'rubygems'
require 'optparse'


module Herokuci

  def self.reflect_state_via_build_light(latest_build_state)
    puts "CI status: #{latest_build_state}"
    BuildLight.new.build_succeeded if latest_build_state == "succeeded"
    BuildLight.new.build_succeeded unless latest_build_state == "succeeded"
  end

  def self.update_build_light_state(application)
    reflect_state_via_build_light(CiApi.new(application).current_status)
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
      puts Herokuci::VERSION
      exit
    end
  end
  option_parser.parse!

  raise OptionParser::MissingArgument if options[:application].nil?

  every_n_seconds(options[:poll]) do
    update_build_light_state(options[:application])
  end
end
