require 'spec_helper'

describe BlobberClient do

  context 'remote storage' do
    let(:url) { 'http://localhost/blobber/' }
    let(:contents) { "foo\nbar\nbaz\n" }

    before do
      WebMock.disable_net_connect!
    end

    it 'should complain bitterly if you try to PUT immutable data.' do
      expected = BlobberClient::PutNotSupported
      lambda { BlobberClient.new().put() }.        should raise_error( expected)
      lambda { BlobberClient.new().put("x") }.     should raise_error( expected)
      lambda { BlobberClient.new().put("x", "y") }.should raise_error( expected)
    end

    # it "retrieves blobs by key" do
    #   stub_request(:get, make_url('deadbeef')).to_return(:status => 200, :body => contents)
    #   client = BlobberClient.new(client_id, client_password, url)
    #   client.get("deadbeef").should == contents
    # end

    # it "returns nil on missing blobs" do
    #   stub_request(:get, make_url('deadbeef')).to_return(:status => 404)
    #   client = BlobberClient.new(client_id, client_password, url)
    #   client.get("deadbeef").should be_nil
    # end

    # it "POSTs blob contents as multipart form data" do
    #   stub_request(:post, make_url()).
    #     to_return(:status => 201, :body => "deadbeef", :headers => { 'Location' => make_url() })
    #   client = BlobberClient.new(client_id, client_password, url)
    #   client.put(contents).should == "deadbeef"
    # end

    # it "raises BlobberClient::UnknownError on 500" do
    #   stub_request(:post, make_url()).to_return(:status => 500)
    #   client = BlobberClient.new(client_id, client_password, url)
    #   expect { client.put(contents) }.to raise_error(BlobberClient::UnknownError)
    # end

  end # context 'remote storage'
end # describe BlobberClient
