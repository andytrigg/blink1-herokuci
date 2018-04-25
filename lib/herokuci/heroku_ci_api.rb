require 'json'

module Herokuci
  class CiApi
    def initialize(application)
      @application = application
    end

    def current_status
      ci_results = `heroku ci -j -w -a #{@application}`
      JSON.parse(ci_results)[0]["status"]
    end
  end
end