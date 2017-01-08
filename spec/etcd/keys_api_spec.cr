require "../spec_helper"

describe Etcd::KeysApi do

  subject {
    client = Etcd.client({"host" => "127.0.0.1", "port" => 2379})
    Etcd::KeysApi.new(client)
  }

  let(:root_key) { "/etcd-specs" }

  before {
    if subject.exists?(root_key)
      subject.rmdir(root_key, true)
    end
  }

  describe "#get" do
    it "returns top-level keys" do
      res = subject.get("/")
      expect(res.node.directory?).to be_truthy
    end

    it "returns a key" do
      subject.set("#{root_key}/foo", "bar")
      res = subject.get("#{root_key}/foo")
      expect(res.node.directory?).to be_falsey
      expect(res.node.value).to eq("bar")
    end

    it "returns a directory with child nodes" do
      2.times do |i|
        subject.set("#{root_key}/dir/node#{i}", i.to_s)
      end
      res = subject.get("#{root_key}/dir/")
      expect(res.node.directory?).to be_truthy
      expect(res.node.children.size).to eq(2)
    end

    it "raises error if key does not exist" do
      expect {
        subject.get("#{root_key}/does_not_exist")
      }.to raise_error(Etcd::KeyNotFound)
    end
  end

  describe "#set" do
    it "sets non-existing key with value" do
      res = subject.set("#{root_key}/foo", "bar")
      expect(res.node.value).to eq("bar")
    end

    it "sets existing key with value" do
      subject.set("#{root_key}/foo", "bar")
      res = subject.set("#{root_key}/foo", "baz")
      expect(res.node.value).to eq("baz")
    end

    it "raises error prev_exist=true and key does not exist" do
      expect {
        subject.set("#{root_key}/foo", "baz", Etcd::KeysApi::SetOptions.new(prev_exist: true))
      }.to raise_error(Etcd::KeyNotFound)
    end

    it "sets key when prev_exist=true and key exists" do
      subject.set("#{root_key}/foo", "bar")
      res = subject.set("#{root_key}/foo", "baz", Etcd::KeysApi::SetOptions.new(prev_exist: true))
      expect(res.node.value).to eq("baz")
    end
  end

  describe "#create_in_order" do
    it "creates a new key" do
      res = subject.create_in_order("#{root_key}/foo", "bar")
      expect(res.node.value).to eq("bar")
    end

    it "raises error if key exists" do
      subject.set("#{root_key}/foo", "foo")
      expect {
        subject.create_in_order("#{root_key}/foo", "bar")
      }.to raise_error(Etcd::NotDir)
    end
  end

  describe "#exists?" do
    it "returns true if key exists" do
      subject.set("#{root_key}/foo", "foo")
      expect(subject.exists?("#{root_key}/foo")).to be_truthy
    end

    it "returns true if key is a directory" do
      subject.mkdir("#{root_key}/dir")
      expect(subject.exists?("#{root_key}/dir")).to be_truthy
    end

    it "returns false if key does not exist" do
      expect(subject.exists?("#{root_key}/does_not_exist")).to be_falsey
    end
  end

  describe "#create" do
    it "creates a new key" do
      res = subject.create("#{root_key}/new", "value")
      expect(res.node.value).to eq("value")
    end

    it "raises an error if key exists" do
      subject.set("#{root_key}/foo", "bar")
      expect {
        subject.create("#{root_key}/foo", "bar")
      }.to raise_error(Etcd::NodeExist)
    end
  end

  describe "#update" do
    it "updates a key" do
      subject.set("#{root_key}/foo", "bar")
      res = subject.update("#{root_key}/foo", "baz")
      expect(res.node.value).to eq("baz")
    end

    it "raises an error if key does not exist" do
      expect {
        subject.update("#{root_key}/foo", "baz")
      }.to raise_error(Etcd::KeyNotFound)
    end
  end

  describe "#delete" do
    it "deletes a key" do
      subject.set("#{root_key}/foo", "bar")
      res = subject.delete("#{root_key}/foo")
      expect(res.node.value).to eq(nil)
    end

    it "raises an error if key does not exist" do
      expect {
        subject.delete("#{root_key}/foo")
      }.to raise_error(Etcd::KeyNotFound)
    end
  end

  describe "#mkdir" do
    it "creates a dir" do
      res = subject.mkdir("#{root_key}/dir")
      expect(res.node.directory?).to be_truthy
    end

    it "raises an error if dir exists" do
      subject.mkdir("#{root_key}/dir")
      expect {
        subject.mkdir("#{root_key}/dir")
      }.to raise_error(Etcd::NodeExist)
    end

    it "raises an error if key exists" do
      subject.set("#{root_key}/dir", "foo")
      expect {
        res = subject.mkdir("#{root_key}/dir")
      }.to raise_error(Etcd::NodeExist)
    end
  end
end
