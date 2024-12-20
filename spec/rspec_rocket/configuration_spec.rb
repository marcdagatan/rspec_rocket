require "spec_helper"

RSpec.describe RSpecRocket::Configuration do
  it "has default values" do
    config = described_class.new
    expect(config.processors).to eq(4)
    expect(config.spec_dir).to eq("spec")
    expect(config.db_strategy).to eq(:transaction)
    expect(config.databases).to eq([])
    expect(config.verbose).to be false
  end

  it "allows overrides" do
    config = described_class.new
    config.processors = 8
    config.spec_dir = "custom_spec"
    config.db_strategy = :separate
    config.databases = ["test_db_1"]
    config.verbose = true

    expect(config.processors).to eq(8)
    expect(config.spec_dir).to eq("custom_spec")
    expect(config.db_strategy).to eq(:separate)
    expect(config.databases).to eq(["test_db_1"])
    expect(config.verbose).to be true
  end
end
