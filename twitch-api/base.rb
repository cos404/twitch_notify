require "./twitch-api/request.rb"

class Base include Request


  def initialize(options = {})
    @client_id = options[:client_id] || nil
    @secret_key = options[:secret_key] || nil
    @redirect_uri = options[:redirect_uri] || nil
    @scope = options[:scope] || nil
    @access_token = options[:token] || nil
    @base_url = "https://api.twitch.tv/kraken"
  end

  def stream(stream_name)
    path = "/streams/#{stream_name}"
    url = @base_url + path + "?client_id=#{@client_id}";
    get(url)
  end

end