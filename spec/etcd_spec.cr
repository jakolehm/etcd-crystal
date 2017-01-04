require "./spec_helper"

describe Etcd do

  describe ".client" do
    it "accepts a hash" do
      client = Etcd.client({"host" => "localhost", "port" => 2379})
      expect(client.class).to eq(Etcd::Client)
    end

    it "accepts a partial hash config" do
      client = Etcd.client({"port" => 2379})
      expect(client.class).to eq(Etcd::Client)
    end
  end
end
