require 'open-uri'
require 'sinatra'
require 'nokogiri'

module Whether

  class HongKongWeather
    def self.now
      new.call
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
      Status.new(hash[:time], hash[:conditions], hash[:temperature])
    end
  end

  class BBCXMLFetcher
    def url
      "http://newsrss.bbc.co.uk/weather/forecast/85/ObservationsRSS.xml"
    end

    def call
      open(url)
    end
  end

  class BBCXMLParser < Struct.new(:xml)

    # <title>Thursday at 00:00 HKT:
    # white cloud. 26&#xB0;C (79&#xB0;F)</title>
    def call
      title_text = nokogiri.xpath('//item/title').text
      _, time, conditions, temperature = *title_text.match(/(\w+ at \d\d\:\d\d HKT)\:\s*(\w[\w ]*\w)\. (\d+)/)

      {time: time, conditions: conditions, temperature: temperature}
    end

    private

    def nokogiri
      @nokogiri ||= Nokogiri::XML(xml)
    end
  end

  class Status < Struct.new(:time, :conditions, :temperature)
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