require 'spec_helper'
require 'whether'

describe Whether::HongKongWeather do

  subject do
    Whether::HongKongWeather.new
  end

  class FakeBBCXMLFetcher
    def call
      File.read("spec/sample.xml")
    end
  end

  it "returns a status" do
    status = subject.call(FakeBBCXMLFetcher.new)
    status.conditions.should == "white cloud"
    status.time.should == "Thursday at 00:00 HKT"
    status.temperature_c.should == "26"
    status.temperature_f.should == "79"
  end
end