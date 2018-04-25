require 'blink1'

module Herokuci
  class BuildLight
    def initialize()
      @light = Blink1.new
    end

    def build_failed
      set_rgb_for_light(255,0,0)
    end

    def build_succeeded
      set_rgb_for_light(0,255,0)
    end

    private

    def set_rgb_for_light(r, g, b)
      @light.open
      @light.set_rgb(r, g, b)
      @light.close
    end
  end
end