require 'open-uri'
require 'sinatra'
require 'nokogiri'

class HongKongWeather < Struct.new(:conditions)
  def self.now
    from_xml(Nokogiri::XML(open("http://newsrss.bbc.co.uk/weather/forecast/85/ObservationsRSS.xml")))
  end

  def self.from_xml(xml)
    title_text = xml.xpath('//item/title').text
    conditions = title_text.split("\n")[1].split(".").first
    self.new(conditions)
  end
end

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
