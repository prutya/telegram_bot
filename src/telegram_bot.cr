require "http/client"
require "logger"
require "uri"

require "./telegram_bot/models"

module TelegramBot
  VERSION = "0.1.0"

  class Client
    def initialize(
      @token       : String,
      @logger      : Logger       = Logger.new(STDOUT),
      @http_client : HTTP::Client =
        HTTP::Client.new(host: "api.telegram.org", tls: true)
    ); end

    def finalize
      @http_client.close
    end

    # https://core.telegram.org/bots/api#setwebhook
    def set_webhook(
      url             : String,
      # certificate : InputFile?,
      max_connections : Int32?         = nil,
      allowed_updates : Array(String)? = nil
    )
      body = {} of String => (String | Integer | Array(String))

      body["url"] = url

      # TODO: Handle certificate

      if max_connections
        body["max_connections"] = max_connections
      end

      if allowed_updates
        body["allowed_updates"] = allowed_updates
      end

      perform_request("setWebhook", body: body)
    end

    # https://core.telegram.org/bots/api#deletewebhook
    def delete_webhook
      perform_request("deleteWebhook")
    end

    # https://core.telegram.org/bots/api#getwebhookinfo
    def get_webhook_info
      perform_request("getWebhookInfo", Models::Result(Models::WebhookInfo))
    end

    # https://core.telegram.org/bots/api#getme
    def get_me
      perform_request("getMe", Models::Result(Models::User))
    end

    # https://core.telegram.org/bots/api#sendmessage
    def send_message(
      chat_id                  : (Int32 | String),
      text                     : String,
      parse_mode               : String?              = nil,
      disable_web_page_preview : Bool?                = nil,
      disable_notification     : Bool?                = nil,
      reply_to_message_id      : Int32?               = nil,
      reply_markup             : Models::ReplyMarkup? = nil
    )
      body = {} of String => (Int32 | String | Bool | Models::ReplyMarkup)

      body["chat_id"] = chat_id
      body["text"]    = text

      if parse_mode
        body["parse_mode"] = parse_mode
      end

      if !disable_web_page_preview.nil?
        body["disable_web_page_preview"] = disable_web_page_preview
      end

      if !disable_notification.nil?
        body["disable_notification"] = disable_notification
      end

      if reply_to_message_id
        body["reply_to_message_id"] = reply_to_message_id
      end

      if reply_markup
        body["reply_markup"] = reply_markup
      end

      perform_request(
        "sendMessage",
        Models::Result(Models::Message),
        body: body
      )
    end

    # https://core.telegram.org/bots/api#editmessagetext
    def edit_message_text(
      text                     : String,
      chat_id                  : (Int32 | String)?             = nil,
      message_id               : Int32?                        = nil,
      inline_message_id        : String?                       = nil,
      parse_mode               : String?                       = nil,
      disable_web_page_preview : Bool?                         = nil,
      reply_markup             : Models::InlineKeyboardMarkup? = nil
    )
      body =
        {} of String => (String | Int32 | Bool | Models::InlineKeyboardMarkup)

      body["text"] = text

      if chat_id
        body["chat_id"] = chat_id
      end

      if message_id
        body["message_id"] = message_id
      end

      if inline_message_id
        body["inline_message_id"] = inline_message_id
      end

      if parse_mode
        body["parse_mode"] = parse_mode
      end

      if !disable_web_page_preview.nil?
        body["disable_web_page_preview"] = disable_web_page_preview
      end

      if reply_markup
        body["reply_markup"] = reply_markup
      end

      perform_request(
        "editMessageText",
        Models::Result(Models::Message),
        body: body
      )
    end

    # https://core.telegram.org/bots/api#deletemessage
    def delete_message(chat_id : (Int32 | String), message_id : Int32)
      perform_request(
        "deleteMessage",
        body: { chat_id: chat_id, message_id: message_id }
      )
    end

    # https://core.telegram.org/bots/api#sendchataction
    def send_chat_action(chat_id : (Int32 | String), action : String)
      perform_request(
        "sendChatAction",
        body: { chat_id: chat_id, action: action }
      )
    end

    # https://core.telegram.org/bots/api#forwardmessage
    def forward_message(
      chat_id              : (Int32 | String),
      from_chat_id         : (Int32 | String),
      message_id           : Int32,
      disable_notification : Bool? = nil
    )
      body = {} of String => (Int32 | String | Bool)

      body["chat_id"]      = chat_id
      body["from_chat_id"] = from_chat_id
      body["message_id"]   = message_id

      if !disable_notification.nil?
        body["disable_notification"] = disable_notification
      end

      perform_request(
        "forwardMessage",
        Models::Result(Models::Message),
        body: body
      )
    end

    # https://core.telegram.org/bots/api#sendphoto
    def send_photo(
      chat_id              : (Int32 | String),
      photo                : String, # TODO: Implement file upload (InputFile)
      caption              : String?              = nil,
      parse_mode           : String?              = nil,
      disable_notification : Bool?                = nil,
      reply_to_message_id  : Int32?               = nil,
      reply_markup         : Models::ReplyMarkup? = nil
    )
      body = {} of String => (Int32 | String | Bool | Models::ReplyMarkup)

      body["chat_id"] = chat_id
      body["photo"]   = photo

      if caption
        body["caption"] = caption
      end

      if parse_mode
        body["parse_mode"] = parse_mode
      end

      if !disable_notification.nil?
        body["disable_notification"] = disable_notification
      end

      if reply_to_message_id
        body["reply_to_message_id"] = reply_to_message_id
      end

      if reply_markup
        body["reply_markup"] = reply_markup
      end

      perform_request(
        "sendPhoto",
        Models::Result(Models::Message),
        body: body
      )
    end

    # https://core.telegram.org/bots/api#sendlocation
    def send_location(
      chat_id              : (Int32 | String),
      latitude             : Float64,
      longitude            : Float64,
      live_period          : Int32?               = nil,
      disable_notification : Bool?                = nil,
      reply_to_message_id  : Int32?               = nil,
      reply_markup         : Models::ReplyMarkup? = nil
    )
      body =
        {} of String => (Int32 | String | Float64 | Bool | Models::ReplyMarkup)

      body["chat_id"]   = chat_id
      body["latitude"]  = latitude
      body["longitude"] = longitude

      if live_period
        body["live_period"] = live_period
      end

      if !disable_notification.nil?
        body["disable_notification"] = disable_notification
      end

      if reply_to_message_id
        body["reply_to_message_id"] = reply_to_message_id
      end

      if reply_markup
        body["reply_markup"] = reply_markup
      end

      perform_request(
        "sendLocation",
        Models::Result(Models::Message),
        body: body
      )
    end

    # https://core.telegram.org/bots/api#sendcontact
    def send_contact(
      chat_id              : (Int32 | String),
      phone_number         : String,
      first_name           : String,
      last_name            : String?              = nil,
      vcard                : String?              = nil,
      disable_notification : Bool?                = nil,
      reply_to_message_id	 : Int32?               = nil,
      reply_markup         : Models::ReplyMarkup? = nil
    )
      body = {} of String => (Int32 | String | Bool | Models::ReplyMarkup?)

      body["chat_id"]      = chat_id
      body["phone_number"] = phone_number
      body["first_name"]   = first_name

      if last_name
        body["last_name"] = last_name
      end

      if vcard
        body["vcard"] = vcard
      end

      if !disable_notification.nil?
        body["disable_notification"] = disable_notification
      end

      if reply_to_message_id
        body["reply_to_message_id"] = reply_to_message_id
      end

      if reply_markup
        body["reply_markup"] = reply_markup
      end

      perform_request(
        "sendContact",
        Models::Result(Models::Message),
        body: body
      )
    end

    private def perform_request(
      endpoint     : String,
      model        : Models::Base.class    = Models::Result(Bool),
      headers      : Hash(String, String)? = nil,
      body         : Object?               = nil,
    ) : Models::Base
      json_body = body.try(&.to_json)

      time_start = Time.monotonic

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

      time_elapsed = Time.monotonic - time_start

      @logger.info("#{endpoint} - #{response.status_code}")

      model.from_json(response.body)
    end
  end
end
