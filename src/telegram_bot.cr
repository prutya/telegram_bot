require "http/client"
require "json"
require "logger"
require "uri"

module TelegramBot
  VERSION = "0.1.0"

  module Models
    abstract struct Base; end

    struct Result(T) < Base
      JSON.mapping(
        {
          ok:          Bool,
          result:      T,
          description: String?
        },
        strict: true
      )
    end

    # https://core.telegram.org/bots/api#webhookinfo
    struct WebhookInfo < Base
      JSON.mapping(
        {
          url:                    String,
          has_custom_certificate: Bool,
          pending_update_count:   Int32,
          last_error_date:        Int32?,
          last_error_message:     String?,
          max_connections:        Int32?,
          allowed_updates:        Array(String)?
        },
        strict: true
      )
    end
  end

  class Client
    @http_client : HTTP::Client
    @token       : String
    @logger      : Logger

    def initialize(
      token : String,
      logger : Logger = Logger.new(STDOUT)
    )
      @http_client = HTTP::Client.new(host: "api.telegram.org", tls: true)
      @token = token
      @logger = logger
    end

    def finalize
      @http_client.close
    end

    # https://core.telegram.org/bots/api#setwebhook
    # TODO: Handle certificates, max_connections, allowed_updates
    def set_webhook(url : String)
      perform_request("setWebhook", body: { url: url })
    end


    # https://core.telegram.org/bots/api#deletewebhook
    def delete_webhook
      perform_request("deleteWebhook")
    end

    # https://core.telegram.org/bots/api#getwebhookinfo
    def get_webhook_info
      perform_request("getWebhookInfo", Models::Result(Models::WebhookInfo))
    end

    private def perform_request(
      endpoint     : String,
      model        : Models::Base.class = Models::Result(Bool),
      headers      : Hash(String, String)? = nil,
      body         : Object? = nil,
    ) : Models::Base
      json_body = body.try(&.to_json)

      response = @http_client.post(
        "/bot#{@token}/#{endpoint}",
        headers: HTTP::Headers.new.tap do |http_headers|
          http_headers["Accept"] = "application/json"

          if json_body
            http_headers["Content-Type"]   = "application/json"
            http_headers["Content-Length"] = json_body.bytesize.to_s
          end

          if headers
            http_headers.merge!(headers)
          end
        end,
        body: json_body
      )

      model.from_json(response.body)
    end
  end
end
