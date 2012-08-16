require "blobber_client/version"
require 'stringio'
require 'rest-client'
require 'tempfile'
require 'cgi'

class BlobberClient
  UnknownError          = 
  CreateFailed          = 
  FetchNonexistentBlob  = 
  DeleteNonexistentBlob = 
  PutNotSupported       = Class.new(StandardError)

  def initialize(base_url = 'http://blobber.cashnetusa.com/blobber')  # FIXME!!! when IT assigns a URL
    @base_url = if base_url[-1] == '/' then
                  base_url.chop
                else
                  base_url
                end
  end

  def post(contents)
    # RestClient.post(sanitize_url(), :contents => contents) 
    RestClient.post(@base_url,
                    contents,
                    :content_type => 'application/octet-stream') do |response, request, result|
      case response.code
      when 201 then response.body
      when 500 then raise CreateFailed.new("Failed to create blob.")
      else          raise UnknownError.new("Unable to handle response code: #{response.code}")
      end
    end
  end

  def get(key)
    RestClient.get("#{@base_url}/#{key}") do |response, request, result|
      case response.code
      when 200 then response.body
      when 410 then raise FetchNonexistentBlob.new("Invalid key: '#{key}'")
      else          raise UnknownError.new("Unable to handle response code: #{response.code}")
      end
    end
  end

  def delete(key)
    RestClient.delete("#{@base_url}/#{key}") do |response, request, result|
      case response.code
      when 200 then response.body
      when 410 then raise DeleteNonexistentBlob.new("Invalid key: '#{key}'")
      else          raise UnknownError.new("Unable to handle response code: #{response.code}")
      end
    end
  end

  def put(*args)
    raise PutNotSupported.new("Blobber data is immutable.  PUT is not supported.")
  end
end
