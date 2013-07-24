require 'open-uri'
require 'sinatra'
require 'nokogiri'

module Whether

  class HongKongWeather
    def self.now
      new.call
    end

    def url
      "http://newsrss.bbc.co.uk/weather/forecast/85/ObservationsRSS.xml"
    end

    def fetch_url
      open(url)
    end

    def parse_url
      Nokogiri::XML(fetch_url)
    end

    def call
      Status.from_xml( parse_url )
    end
  end

  class Status < Struct.new(:time, :conditions, :temperature)

    # <title>Thursday at 00:00 HKT:
    # white cloud. 26&#xB0;C (79&#xB0;F)</title>
    def self.from_xml(xml)
      title_text = xml.xpath('//item/title').text
      _, time, conditions, temperature = *title_text.match(/(\w+ at \d\d\:\d\d HKT)\:\s*(\w[\w ]*\w)\. (\d+)/)
      self.new(time, conditions, temperature)
    end
  end

  class App < Sinatra::Application
    helpers do

      def weather_picture(string)
        case string
        when "white cloud" then "cloudy5.png"
        when "grey cloud" then "overcast.png"
        when "light rain" then "light_rain.png"
        end
      end

      def weather_picture_tag(string)
        if picture = weather_picture(string)
          %(<img src="/icons/#{picture}" alt=#{string.inspect} />)
        end
      end

    end

    get '/' do
      expires 10*60
      @weather = HongKongWeather.now
      haml :index
    end
  end
end