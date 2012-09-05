require 'simplecov'
SimpleCov.start

require 'rspec'
require 'blobber_client'
require 'fileutils'
require 'tempfile'


describe BlobberClient do

  context 'Live test with a running blob server.' do

    before :all do
      @url = ENV['BLOBBER_URL'] || 'http://localhost:3000/'
      @counter = 0
      if ENV['BLOBBER_TRUST_ALL_SSL_CERTIFICATES']
        require 'openssl'
        OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
        STDERR.puts "Setting OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE"
      end
    end

    before :each do
      @blob = 'Test blob #{@counter} from blobber-client/spec/integration_with_live_server_spec.rb'
      @key  = BlobberClient.new(@url).post( @blob )
      @counter = @counter + 1
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

      lambda { BlobberClient.new(@url).get( mal_formed_key ) }.should raise_error( expected)
    end

    it 'GET should treat a 410 as non-existent blob and raise an error' do 
      good_key_matches_guuid_regexp = '04cd2073-8075-4c0d-a979-4fb730249a0a'
      expected                      = BlobberClient::FetchNonexistentBlob

      lambda { BlobberClient.new(@url).get( good_key_matches_guuid_regexp) }.should raise_error( expected)
    end

    it 'POST should return a key when successful' do
      blob = 'JFK Axis of Evil AIMSX North Korea Baranyi AMW World Trade Center analyzer InfoSec'

      lambda { key = BlobberClient.new(@url).post( blob ) 
               key.should =~ /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/
             }.should_not raise_error
    end

    it 'DELETE should return the key and not raise an error, when successful' do
      lambda { x = BlobberClient.new(@url).delete( @key )
               x.should == @key 
             }.should_not raise_error
    end

    it 'DELETE should raise an error, when trying to delete a non-existent key' do
      expected = BlobberClient::DeleteNonexistentBlob
      nonexistent_key = '04cd2073-8075-4c0d-a979-4fb730249a0a'

      lambda { BlobberClient.new(@url).delete( nonexistent_key ) }.should raise_error( expected)
    end

  end # context 'remote storage'

  context 'Live data integrity test using arbitrary binary data with a running blob server.' do

    before :all do
      @url = ENV['BLOBBER_URL'] || 'http://localhost:3000/'

      if ENV['BLOBBER_TRUST_ALL_SSL_CERTIFICATES']
        require 'openssl'
        OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
        STDERR.puts "Setting OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE"
      end

      @client   = BlobberClient.new(@url)
      @blob     = File.open( '/dev/urandom', 'rb') { |f| f.read( 1024 * 1024) }
      @original = Tempfile.new( 'blobber-client')

      @original.write( @blob)
    end

    it 'should POST arbitrary binary data and GET the data unchanged (internal string comparison)' do
      key    = @client.post( @blob )
      result = @client.get( key )
    end

    it 'should POST arbitrary binary data and GET the data unchanged (external file comparison)' do
      key    = @client.post( @blob )
      blob   = @client.get( key )
      copy   = Tempfile.new( 'blobber-client')
      copy.write( blob)
      FileUtils.compare_file( @original, copy).should == true
    end
  end # context 'Live data integrity'

end # describe BlobberClient
