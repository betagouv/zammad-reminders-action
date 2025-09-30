require "faraday"
require "uri"

class MattermostApiClient
  def self.connection
    @connection ||= Faraday.new(
      url: webhook_uri.scheme + "://" + webhook_uri.host + ":" + webhook_uri.port.to_s
    ) do |builder|
      builder.request :json
      builder.response :json
      builder.response :raise_error # raise an error on 4xx and 5xx responses
    end
  end

  def self.send_message(channel:, text:)
    connection.post(
      webhook_uri.path,
      {
        channel:,
        text:,
        username: "Zammad",
        icon_url: "https://raw.githubusercontent.com/zammad/zammad/refs/heads/develop/public/assets/images/logo.svg"
      }.to_json,
    )
  end

  def self.webhook_uri
    @webhook_uri ||= URI.parse(ENV["MATTERMOST_WEBHOOK_URL"])
  end
end
