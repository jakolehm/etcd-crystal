require "../spec_helper"

describe Etcd::Client do

  subject {
    Etcd.client({"host" => "127.0.0.1", "port" => 2379})
  }

  let(:root_key) { "/etcd-specs" }

  before {
    if subject.keys.exists?(root_key)
      subject.keys.rmdir(root_key, true)
    end
  }

  context "#keys" do
    describe "#get" do
      it "returns top-level keys" do
        res = subject.keys.get("/")
        expect(res.node.directory?).to be_truthy
      end
    end

    describe "#set" do
      it "sets non-existing key with value" do
        res = subject.keys.set("#{root_key}/foo", "bar")
        expect(res.node.value).to eq("bar")
      end

      it "sets existing key with value" do
        subject.keys.set("#{root_key}/foo", "bar")
        res = subject.keys.set("#{root_key}/foo", "baz")
        expect(res.node.value).to eq("baz")
      end

      it "raises error prev_exist=true and key does not exist" do
        expect {
          subject.keys.set("#{root_key}/foo", "baz", Etcd::KeysApi::SetOptions.new(prev_exist: true))
        }.to raise_error(Etcd::KeyNotFound)
      end

      it "sets key when prev_exist=true and key exists" do
        subject.keys.set("#{root_key}/foo", "bar")
        res = subject.keys.set("#{root_key}/foo", "baz", Etcd::KeysApi::SetOptions.new(prev_exist: true))
        expect(res.node.value).to eq("baz")
      end
    end
  end
end
