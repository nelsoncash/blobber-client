### This is the ORIGINAL BlobClient::RemoteStore for reference

require 'stringio'
require 'rest-client'
require 'tempfile'

class BlobClient
  class RemoteStore
    def initialize(base_url = 'http://blobs.cashnetusa.com')
      @base_url = base_url
    end

    def get(sha)
      RestClient.get("#{@base_url}/blobs/#{sha}") do |response, request, result|
        case response.code
        when 200 then response.body
        when 404 then nil
        end
      end
    end

    def put(contents)
      with_tempfile contents do |file|
        RestClient.post("#{@base_url}/blobs", :contents => file) do |response, request, result|
          case response.code
          when 201, 301 then response.body
          when 409 then raise BlobClient::Conflict.new(response.body)
          else raise BlobClient::UnknownError.new("Unable to handle response code: #{response.code}")
          end
        end
      end
    end

    private

    def with_tempfile(contents)
      tf = Tempfile.new('blob_client')
      tf.write contents
      tf.rewind
      yield tf
    ensure
      tf.close
      tf.unlink
    end
  end
end
