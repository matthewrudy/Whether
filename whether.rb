require 'open-uri'
require 'sinatra'
require 'nokogiri'

def the_weather
  noko = Nokogiri::XML(open("http://newsrss.bbc.co.uk/weather/forecast/85/ObservationsRSS.xml"))
  text = noko.xpath('//item/title').text
  text.split("\n")[1].split(".").first
end

helpers do

  def weather_picture(string)
    case string
    when "grey cloud" then "cloudy5.png"
    end
  end

  def weather_picture_or_string(string)
    if picture = weather_picture(string)
      %(<img src="/icons/#{picture}" />)
    else
      string.inspect
    end
  end
  
end

get '/' do
  expires 10*60
  @the_weather = the_weather
  erubis :index
end
