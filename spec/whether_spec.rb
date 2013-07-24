require 'spec_helper'
require 'whether'

describe Whether::HongKongWeather do

  subject do
    Whether::HongKongWeather.new
  end

  before do
    subject.should_receive(:fetch_url).and_return(File.open("spec/sample.xml"))
  end

  it "is returns a status" do
    status = subject.call
    status.conditions.should == "white cloud"
    status.time.should == "Thursday at 00:00 HKT"
    status.temperature.should == "26"
  end
end