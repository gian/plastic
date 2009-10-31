require File.dirname(__FILE__) + '/../spec_helper'

describe Plastic do
  before :each do
    @instance = described_class.new
  end

  describe "#parse_tracks!" do
    it "calls #parse_track_2, then #parse_track_1" do
      @instance.should_receive(:parse_track_2!).with().once
      @instance.should_receive(:parse_track_1!).with().once.and_raise(StandardError)
      lambda { @instance.parse_tracks! }.should raise_error(StandardError)
    end
  end

  describe "#parse_track!" do
    it "calls #parse_track_2, then #parse_track_1" do
      arg = "foo"
      @instance.should_receive(:parse_track_2!).with(arg).once
      @instance.should_receive(:parse_track_1!).with(arg).once.and_raise(StandardError)
      lambda { @instance.parse_track! arg }.should raise_error(StandardError)
    end
  end

  describe "self.track_1_parser" do
    it "returns a regular expression" do
      described_class.track_1_parser.should be_instance_of(Regexp)
    end
  end

  describe "#parse_track_1!" do
    def mock_track_1_parser
      parser = mock()
      described_class.should_receive(:track_1_parser).once.and_return(parser)
      parser
    end

    it "with no arguments parses the contents of #track_1" do
      arg = "foo"
      @instance.should_receive(:track_1).once.and_return(arg)
      mock_track_1_parser.should_receive(:match).with(arg).once
      @instance.parse_track_1!
    end

    it "with nil parses the contents of #track_1" do
      arg = "foo"
      @instance.should_receive(:track_1).once.and_return(arg)
      mock_track_1_parser.should_receive(:match).with(arg).once
      @instance.parse_track_1! nil
    end

    [0, 1, "foo", "bar", StandardError].each do |value|
      it "with #{value} attempts to parse the string representation" do
        mock_track_1_parser.should_receive(:match).with(value.to_s).once
        @instance.parse_track_1! value
      end
    end

    [
      ["", nil, nil, nil],
      ["foobar", nil, nil, nil],
      ["B1^N^1230", nil, nil, nil],
      ["%B1^N^1230?", nil, nil, nil],
      ["B12345678901234567890^CW^1010123", nil, nil, nil],
      ["B123456789012^CW^0909123", "123456789012", "CW", "0909"],
      ["B123456789012345^Dorsey/Jack^1010123", "123456789012345", "Dorsey/Jack", "1010"],
      ["%B123456789012345^Dorsey/Jack^1010123;", "123456789012345", "Dorsey/Jack", "1010"],
    ].each do |value, pan, name, expiration|
      it "with \"#{value}\" correctly parses pan, name and expiration" do
        @instance.parse_track_1! value
        @instance.pan.should == pan
        @instance.name.should == name
        @instance.expiration.should == expiration
      end
    end
  end
end
