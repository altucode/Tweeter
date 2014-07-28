require 'yaml'
require 'open-uri'

class TwitterSession
  def self.get(path, query_values)
    response = self.access_token.get(self.path_to_url(path, query_values)).body
    JSON.parse(response)
  end

  def self.post(path, req_params)
  end

  def self.path_to_url(path, query_values = nil)
    Addressable::URI.new(
    :scheme => 'https',
    :host => 'api.twitter.com',
    :path => "/1.1/#{path}.json",
    :query_values => query_values
    ).to_s
  end

  def self.connected?
    begin
      true if open("http://www.google.com/")
    rescue
      false
    end
  end

  private
  TOKEN_FILE = 'access_token.yml'
  def self.access_token
    if File.exist?(TOKEN_FILE)
      File.open(TOKEN_FILE) { |f| YAML.load(f) }
    else
      access_token = request_access_token
      File.open(TOKEN_FILE, 'w') { |f| YAML.dump(access_token, f) }
      access_token
    end
  end
  def self.request_access_token
    consumer = OAuth::Consumer.new(self.get_key, self.get_secret, :site => "https://twitter.com")
    request_token = consumer.get_request_token
    authorize_url = request_token.authorize_url

    puts "Go to this URL: #{authorize_url}"
    Launchy.open(authorize_url)

    puts "Login, and type your verification code in"
    oauth_verifier = gets.chomp

    request_token.get_access_token(
      :oauth_verifier => oauth_verifier
      )
  end
  def self.get_key
    api_key = nil
    begin
      api_key = File.read('.api_key').chomp
    rescue
      puts "Unable to read '.api_key'. Please provide a valid Twitter API key."
      exit
    end
  end
  def self.get_secret
    api_secret = nil
    begin
      api_secret = File.read('.api_secret').chomp
    rescue
      puts "Unable to read '.api_secret'. Please provide a valid Twitter API secret."
      exit
    end
  end

end

