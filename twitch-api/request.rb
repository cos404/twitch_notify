require 'httparty'

# Request handler
module Request
  def get(url)
    HTTParty.get(url).parsed_response
  end
end
