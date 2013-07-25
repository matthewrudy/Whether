require 'open-uri'
require 'sinatra'
require 'nokogiri'

module Whether

  class HongKongWeather

    def self.now_cached
      self.new.call CachingDelegator.new(BBCXMLFetcher.new, "bbc:weather:hongkong")
    end

    def self.now
      self.new.call
    end

    def fetch_url
      open(url)
    end

    def parse
      Nokogiri::XML(fetch_url)
    end

    def call(fetcher=BBCXMLFetcher.new)
      xml = fetcher.call
      hash = BBCXMLParser.new(xml).call
      Status.new(hash[:time], hash[:conditions], hash[:temperature_c], hash[:temperature_f])
    end
  end

  class BBCXMLFetcher
    def url
      "http://newsrss.bbc.co.uk/weather/forecast/85/ObservationsRSS.xml"
    end

    def call
      open(url).read
    end
  end

  require 'memcachier'
  require 'dalli'

  class CachingDelegator

    def initialize(target, cache_key)
      @target = target
      @cache_key = cache_key
    end

    def call
      cache_client.fetch(@cache_key, cache_expiry) do
        @target.call
      end
    end

    private

    def cache_expiry
      5*60 # 5 minutes
    end

    def cache_client
      @cache_client ||= Dalli::Client.new
    end
  end

  class BBCXMLParser < Struct.new(:xml)

    # <title>Thursday at 00:00 HKT:
    # white cloud. 26&#xB0;C (79&#xB0;F)</title>
    def call
      title_text = nokogiri.xpath('//item/title').text
      _, time, conditions, temperature_c, temperature_f = *title_text.match(/(\w+ at \d\d\:\d\d HKT)\:\s*(\w[\w ]*\w)\. (\d+).+C \((\d+).+F\)/)

      {time: time, conditions: conditions, temperature_c: temperature_c, temperature_f: temperature_f}
    end

    private

    def nokogiri
      @nokogiri ||= Nokogiri::XML(xml)
    end
  end

  class Status < Struct.new(:time, :conditions, :temperature_c, :temperature_f)
  end

  class App < Sinatra::Application
    helpers do

      def weather_picture(string)
        case string
        when "white cloud" then "cloudy5.png"
        when "grey cloud" then "overcast.png"
        when "light rain", "light rain shower" then "light_rain.png"
        end
      end

      def weather_picture_tag(string)
        if picture = weather_picture(string)
          %(<img src="/icons/#{picture}" alt=#{string.inspect} />)
        end
      end

    end

    get '/' do
      @weather = HongKongWeather.now_cached
      haml :index
    end
  end
end