require "./spec_helper"

describe Discovery do
  # TODO: Write tests

  describe "#travis" do
    it "has basic stuff telling travis to shut up" do
      travis = Discovery.new
      travis.should contain("work travis")
    end
  end
end

