require "spec_helper"

RSpec.describe RSpecRocket::CLI do
  before do
    allow(Dir).to receive(:[]).and_return(["spec/example_spec.rb"])
    allow(RSpecRocket::Runner).to receive(:run)
  end

  it "runs tests via runner when specs are found" do
    described_class.start
    expect(RSpecRocket::Runner).to have_received(:run)
  end

  it "exits if no specs are found" do
    allow(Dir).to receive(:[]).and_return([])
    expect { described_class.start }.to raise_error(SystemExit)
  end

  it "applies CLI options to configuration" do
    ARGV.replace(["--processors", "8", "--verbose"])
    described_class.start
    expect(RSpecRocket.configuration.processors).to eq(8)
    expect(RSpecRocket.configuration.verbose).to be true
  ensure
    ARGV.clear
  end
end
