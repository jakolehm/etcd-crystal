require "../spec_helper"

describe Etcd::Client do

  subject {
    Etcd.client({"host" => "127.0.0.1", "port" => 2379})
  }

  describe "#version" do
    it "returns version hash" do
      version = subject.version
      expect(version["etcdserver"]).not_to be_nil
      expect(version["etcdcluster"]).not_to be_nil
    end
  end
end
