RSpec.describe "An example test suite" do # rubocop:disable RSpec/DescribeClass
  it "runs a basic test" do
    expect(1 + 1).to eq(2)
  end

  it "runs another basic test" do
    expect("foo".upcase).to eq("FOO")
  end

  context "when nested context" do
    it "runs yet another test" do
      arr = [1, 2, 3]
      expect(arr).to include(2)
    end
  end
end
