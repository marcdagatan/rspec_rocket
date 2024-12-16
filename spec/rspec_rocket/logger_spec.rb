require "spec_helper"

RSpec.describe RSpecRocket::Logger do
  before do
    described_class.configure(level: :info)
  end

  it "logs at info level by default" do
    expect { described_class.info("test info") }.to output(/test info/).to_stdout_from_any_process
  end

  it "allows changing log level to debug" do
    described_class.configure(level: :debug)
    expect { described_class.debug("test debug") }.to output(/test debug/).to_stdout_from_any_process
  end

  it "logs warnings and errors" do
    expect { described_class.warn("warn message") }.to output(/warn message/).to_stdout_from_any_process
    expect { described_class.error("error message") }.to output(/error message/).to_stdout_from_any_process
  end
end
