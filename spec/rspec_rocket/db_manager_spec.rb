require "spec_helper"

# Minimal fake classes to verify doubles against
class FakeConnection
  def create_database(_name); end
  def drop_database(_name); end
end

class FakeDBConfigObj
  attr_reader :configuration_hash

  def initialize(config_hash)
    @configuration_hash = config_hash
  end
end

RSpec.describe RSpecRocket::DBManager do
  let(:processors) { 4 }
  let(:databases) { [] }
  let(:database_cleaner) { class_spy(DatabaseCleaner) }

  before do
    # Replace DatabaseCleaner references with a class spy
    stub_const("DatabaseCleaner", database_cleaner)
  end

  context "when a database is present" do
    let(:connection) { instance_spy(FakeConnection) }

    before do
      allow(ActiveRecord::Base).to receive(:connection).and_return(connection)
    end

    it "sets up transaction strategy" do
      manager = described_class.new(:transaction, processors, databases)
      manager.setup
      expect(database_cleaner).to have_received(:strategy=).with(:transaction)
      expect(database_cleaner).to have_received(:clean_with).with(:truncation)
    end

    it "starts and cleans transaction per thread" do
      manager = described_class.new(:transaction, processors, databases)
      manager.setup

      manager.before_each_thread
      expect(database_cleaner).to have_received(:start)

      manager.after_each_thread
      expect(database_cleaner).to have_received(:clean)
    end

    context "when using separate databases" do
      let(:databases) { %w[test_db_1 test_db_2] }

      let(:db_config_obj) { FakeDBConfigObj.new("adapter" => "sqlite3", "database" => ":memory:") }

      before do
        # Instead of message chain, stub methods directly
        allow(ActiveRecord::Base.configurations).to receive(:find_db_config).with("test").and_return(db_config_obj)
        allow(ActiveRecord::Base).to receive(:establish_connection)
      end

      it "creates separate databases" do
        manager = described_class.new(:separate, processors, databases)
        manager.setup
        expect(connection).to have_received(:create_database).twice
      end

      it "tears down separate databases" do
        manager = described_class.new(:separate, processors, databases)
        manager.setup
        manager.teardown
        expect(connection).to have_received(:drop_database).twice
      end
    end
  end

  context "when no database is present" do
    before do
      allow(ActiveRecord::Base).to receive(:connection).and_raise(ActiveRecord::ConnectionNotEstablished)
    end

    it "skips DB setup gracefully" do
      manager = described_class.new(:transaction, processors, databases)
      expect { manager.setup }.not_to raise_error
      # No calls to DatabaseCleaner since DB not present
      expect(database_cleaner).not_to have_received(:strategy=)
    end
  end
end
