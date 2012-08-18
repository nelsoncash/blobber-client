require "blobber_client/version"
require 'rest-client'

class BlobberClient
  class Error < StandardError; end

  class UnknownError          < Error; end
  class CreateFailed          < Error; end
  class FetchNonexistentBlob  < Error; end
  class DeleteNonexistentBlob < Error; end
  class PutNotSupported       < Error; end
  class MalformedKey          < Error; end

  def initialize(base_url)
    @base_url = if base_url[-1] == '/' then
                  base_url.chop
                else
                  base_url
                end
    rescue StandardError => e; raise Error.new(e.inspect)
  end

  def post(contents)
    RestClient.post(@base_url,
                    contents,
                    :content_type => 'application/octet-stream') do |response, request, result|
      case response.code
      when 201 then response.body
      when 500 then raise CreateFailed.new("Failed to create blob.")
      else          raise UnknownError.new("Unable to handle response code: #{response.code}")
      end
    end
    rescue CreateFailed, UnknownError; raise
    rescue StandardError => e; raise Error.new(e.inspect)
  end

  def get(key)
    RestClient.get("#{@base_url}/#{key}") do |response, request, result|
      case response.code
      when 200 then response.body
      when 410 then raise FetchNonexistentBlob.new("Invalid key: '#{key}'")
      when 404 then raise MalformedKey.new("Malformed key: '#{key}'")
      else          raise UnknownError.new("Unable to handle response code: #{response.code}")
      end
    end
    rescue FetchNonexistentBlob, MalformedKey, UnknownError; raise
    rescue StandardError => e; raise Error.new(e.inspect)
  end

  def delete(key)
    RestClient.delete("#{@base_url}/#{key}") do |response, request, result|
      case response.code
      when 200 then response.body
      when 410 then raise DeleteNonexistentBlob.new("Invalid key: '#{key}'")
      else          raise UnknownError.new("Unable to handle response code: #{response.code}")
      end
    end
    rescue DeleteNonexistentBlob, UnknownError;  raise
    rescue StandardError => e; raise Error.new(e.inspect)
  end

  def put(*args)
    raise PutNotSupported.new("Blobber data is immutable.  PUT is not supported.")
  end
end
