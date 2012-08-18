require 'spec_helper'

describe BlobberClient do

  context 'remote storage' do

    before do
      WebMock.disable_net_connect!
      @url = 'http://example.com'
    end

    it 'should let no exceptions escape unless derived from BlobberClient::Error ' do
      not_a_url_string = 42.0
      lambda { BlobberClient.new( not_a_url_string) }.should raise_error(BlobberClient::Error)
    end

    it "should strip trailing '/' from the url argument to #new" do
      good = @url
      bad  = "#{@url}/"
      BlobberClient.new( bad). instance_variable_get('@base_url').should == good
      BlobberClient.new( good).instance_variable_get('@base_url').should == good
    end

    it 'PUT should not be supported and should raise an error if you try (Blobber data is immutable)' do
      expected = BlobberClient::PutNotSupported
      lambda { BlobberClient.new(@url).put() }.        should raise_error( expected)
      lambda { BlobberClient.new(@url).put("x") }.     should raise_error( expected)
      lambda { BlobberClient.new(@url).put("x", "y") }.should raise_error( expected)
    end

    it 'GET should treat a 404 as indication of a malformed key and raise an error' do 
      mal_formed_key = '0xDEADBEEF'
      expected       = BlobberClient::MalformedKey

      stub_request(:get, "#{@url}/0xDEADBEEF").
        with(:headers => {
               'Accept'          =>'*/*; q=0.5, application/xml',
               'Accept-Encoding' =>'gzip, deflate', 
               'User-Agent'      =>'Ruby'}).
        to_return(:status => 404, :body => "", :headers => {})

      lambda { BlobberClient.new(@url).get( mal_formed_key ) }.should raise_error( expected)
    end

    it 'GET should treat a 410 as non-existent blob and raise an error' do 
      good_key_matches_guuid_regexp = '04cd2073-8075-4c0d-a979-4fb730249a0a'
      expected                      = BlobberClient::FetchNonexistentBlob

      stub_request(:get, "#{@url}/04cd2073-8075-4c0d-a979-4fb730249a0a").
        with(:headers => {
               'Accept'          =>'*/*; q=0.5, application/xml',
               'Accept-Encoding' =>'gzip, deflate',
               'User-Agent'      =>'Ruby'}).
        to_return(:status => 410, :body => "", :headers => {})

      lambda { BlobberClient.new(@url).get( good_key_matches_guuid_regexp) }.should raise_error( expected)
    end

    it 'POST should return a key when successful' do
      blob = 'JFK Axis of Evil AIMSX North Korea Baranyi AMW World Trade Center analyzer InfoSec'

      stub_request(:post, @url).
        with(:body => blob,
             :headers => {
               'Accept'          =>'*/*; q=0.5, application/xml',
               'Accept-Encoding' =>'gzip, deflate',
               'Content-Length'  =>'82',
               'Content-Type'    =>'application/octet-stream',
               'User-Agent'      =>'Ruby'}).
        to_return(:status => 201, :body => '04cd2073-8075-4c0d-a979-4fb730249a0a', :headers => {})

      lambda { BlobberClient.new(@url).post( blob ) }.should_not raise_error
    end

    it 'POST should raise an error when the server reports failure with an HTTP 500' do
      expected = BlobberClient::CreateFailed
      blob = 'Exon Shell SEAL Team 6 Venezuela Armani World Trade Center Becker Janet Reno PET BRLO cybercash'

       stub_request(:post, @url).
         with(:body => blob,
              :headers => {
                'Accept'          =>'*/*; q=0.5, application/xml',
                'Accept-Encoding' =>'gzip, deflate',
                'Content-Length'  =>'95',
                'Content-Type'    =>'application/octet-stream',
                'User-Agent'      =>'Ruby'}).
         to_return(:status => 500, :body => "", :headers => {})

      lambda { BlobberClient.new(@url).post( blob ) }.should raise_error( expected)
    end


    it 'DELETE should return the key and not raise an error, when successful' do
      good_key_matches_guuid_regexp = '04cd2073-8075-4c0d-a979-4fb730249a0a'

      stub_request(:delete, "#{@url}/#{good_key_matches_guuid_regexp}").
         with(:headers => {
                'Accept'          =>'*/*; q=0.5, application/xml',
                'Accept-Encoding' =>'gzip, deflate',
                'User-Agent'      =>'Ruby'}).
         to_return(:status => 200, :body => good_key_matches_guuid_regexp, :headers => {})

      lambda { BlobberClient.new(@url).delete( good_key_matches_guuid_regexp ) }.should_not raise_error
      BlobberClient.new(@url).delete( good_key_matches_guuid_regexp ).should == good_key_matches_guuid_regexp
    end

    it 'DELETE should raise an error, when trying to delete a non-existent key' do
      expected = BlobberClient::DeleteNonexistentBlob
      nonexistent_key = '04cd2073-8075-4c0d-a979-4fb730249a0a'

      stub_request(:delete, "#{@url}/#{nonexistent_key}").
         with(:headers => {
                'Accept'          =>'*/*; q=0.5, application/xml',
                'Accept-Encoding' =>'gzip, deflate',
                'User-Agent'      =>'Ruby'}).
         to_return(:status => 410, :body => nonexistent_key, :headers => {})

      lambda { BlobberClient.new(@url).delete( nonexistent_key ) }.should raise_error( expected)
    end

  end # context 'remote storage'
end # describe BlobberClient
