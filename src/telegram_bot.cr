require "http/client"
require "log"
require "uri"

require "./telegram_bot/models"

module TelegramBot
  VERSION = "1.6.0"

  Log = ::Log.for("telegram_bot")

  enum ParseMode
    Markdown
    MarkdownV2
    HTML
  end

  class Client
    Log = TelegramBot::Log.for("client")

    getter token : String

    def initialize(
      @token       : String,
      @http_client : HTTP::Client = HTTP::Client.new(host: "api.telegram.org", tls: true),
      @random      : Random       = Random::Secure
    ); end

    def finalize
      @http_client.close
    end

    # NOTE: Avoid using this method. Prefer webhooks.
    def listen
      offset = 0

      loop do
        result = get_updates(offset: offset, timeout: 30)

        unless result.ok
          next
        end

        unless updates = result.result.as?(Array(Models::Update))
          next
        end

        if updates.empty?
          next
        end

        offset = updates.last.update_id + 1

        updates.each { |update| yield update }
      end
    end

    # https://core.telegram.org/bots/api#getupdates
    def get_updates(
      offset          : Int32? = nil,
      limit           : Int32? = nil,
      timeout         : Int32? = nil,
      allowed_updates : Array(String)? = nil
    )
      body = {} of String => (Int32 | Array(String))

      if offset
        body["offset"] = offset
      end

      if limit
        body["limit"] = limit
      end

      if timeout
        body["timeout"] = timeout
      end

      if allowed_updates
        body["allowed_updates"] = allowed_updates
      end

      perform_request(
        "getUpdates",
        Models::Result(Array(Models::Update)),
        body: body
      )
    end

    # https://core.telegram.org/bots/api#setwebhook
    def set_webhook(
      url             : String,
      certificate     : IO?            = nil,
      max_connections : Int32?         = nil,
      allowed_updates : Array(String)? = nil
    )
      io = IO::Memory.new

      boundary = @random.hex(20)

      HTTP::FormData.build(io, boundary) do |formdata|
        formdata.field("url", url)

        if certificate
          formdata.file(
            "certificate",
            certificate,
            HTTP::FormData::FileMetadata.new(filename: "certificate")
          )
        end

        if max_connections
          formdata.field("max_connections", max_connections)
        end

        if allowed_updates
          formdata.field("allowed_updates", allowed_updates.to_json)
        end
      end

      body = io.to_s

      io.close

      time_start = Time.monotonic

      response = @http_client.post(
        "/bot#{@token}/setWebhook",
        headers: HTTP::Headers{
          "Accept" => "application/json",
          "Content-Type" => "multipart/form-data; boundary=#{boundary}",
          "Content-Length" => body.bytesize.to_s
        },
        body: body
      )

      elapsed = Time.monotonic - time_start
      elapsed_str = -> () { elapsed.total_seconds < 1 ? elapsed.total_seconds.humanize(precision: 2, significant: false) : elapsed.total_seconds }

      Log.for("setWebhook").info { "#{response.status_code} - #{elapsed_str.call}s" }

      Models::Result(Bool).from_json(response.body)
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
      chat_id                  : (Int64 | String),
      text                     : String,
      parse_mode               : (ParseMode | String)? = nil,
      disable_web_page_preview : Bool?                 = nil,
      disable_notification     : Bool?                 = nil,
      reply_to_message_id      : Int32?                = nil,
      reply_markup             : Models::ReplyMarkup?  = nil
    )
      body = {} of String => (Int64 | String | Bool | Int32 | Models::ReplyMarkup)

      body["chat_id"] = chat_id
      body["text"]    = text

      if parse_mode
        body["parse_mode"] = parse_mode.to_s
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
      chat_id                  : (Int64 | String)?             = nil,
      message_id               : Int32?                        = nil,
      inline_message_id        : String?                       = nil,
      parse_mode               : (ParseMode | String)?         = nil,
      disable_web_page_preview : Bool?                         = nil,
      reply_markup             : Models::InlineKeyboardMarkup? = nil
    )
      body =
        {} of String => (String | Int64 | Int32 | Bool | Models::InlineKeyboardMarkup)

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
        body["parse_mode"] = parse_mode.to_s
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

    # https://core.telegram.org/bots/api#editmessagereplymarkup
    def edit_message_reply_markup(
      chat_id                  : (Int64 | String)?             = nil,
      message_id               : Int32?                        = nil,
      inline_message_id        : String?                       = nil,
      reply_markup             : Models::InlineKeyboardMarkup? = nil
    )
      body =
        {} of String => (Int64 | String | Int32 | Bool | Models::InlineKeyboardMarkup)

      if chat_id
        body["chat_id"] = chat_id
      end

      if message_id
        body["message_id"] = message_id
      end

      if inline_message_id
        body["inline_message_id"] = inline_message_id
      end

      if reply_markup
        body["reply_markup"] = reply_markup
      end

      perform_request(
        "editMessageReplyMarkup",
        Models::Result(Models::Message),
        body: body
      )
    end

    # https://core.telegram.org/bots/api#deletemessage
    def delete_message(chat_id : (Int64 | String), message_id : Int32)
      perform_request(
        "deleteMessage",
        body: { chat_id: chat_id, message_id: message_id }
      )
    end

    # https://core.telegram.org/bots/api#sendchataction
    def send_chat_action(chat_id : (Int64 | String), action : String)
      perform_request(
        "sendChatAction",
        body: { chat_id: chat_id, action: action }
      )
    end

    # https://core.telegram.org/bots/api#forwardmessage
    def forward_message(
      chat_id              : (Int64 | String),
      from_chat_id         : (Int64 | String),
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
      chat_id              : (Int64 | String),
      photo                : String,
      caption              : String?                = nil,
      parse_mode           : (ParseMode | String)?  = nil,
      disable_notification : Bool?                  = nil,
      reply_to_message_id  : Int32?                 = nil,
      reply_markup         : Models::ReplyMarkup?   = nil
    )
      body = {} of String => (Int64 | Int32 | String | Bool | Models::ReplyMarkup)

      body["chat_id"] = chat_id
      body["photo"]   = photo

      if caption
        body["caption"] = caption
      end

      if parse_mode
        body["parse_mode"] = parse_mode.to_s
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

    def send_photo(
      chat_id              : (Int64 | String),
      photo                : IO,
      caption              : String?               = nil,
      parse_mode           : (ParseMode | String)? = nil,
      disable_notification : Bool?                 = nil,
      reply_to_message_id  : Int32?                = nil,
      reply_markup         : Models::ReplyMarkup?  = nil
    )
      io = IO::Memory.new

      boundary = @random.hex(20)

      HTTP::FormData.build(io, boundary) do |formdata|
        formdata.field("chat_id", chat_id)

        formdata.file(
          "photo",
          photo,
          HTTP::FormData::FileMetadata.new(filename: "photo")
        )

        if caption
          formdata.field("caption", caption)
        end

        if parse_mode
          formdata.field("parse_mode", parse_mode.to_s)
        end

        if !disable_notification.nil?
          formdata.field("disable_notification", disable_notification)
        end

        if reply_to_message_id
          formdata.field("reply_to_message_id", reply_to_message_id)
        end

        if reply_markup
          formdata.field("reply_markup", reply_markup.to_json)
        end
      end

      body = io.to_s

      io.close

      time_start = Time.monotonic

      response = @http_client.post(
        "/bot#{@token}/sendPhoto",
        headers: HTTP::Headers{
          "Accept" => "application/json",
          "Content-Type" => "multipart/form-data; boundary=#{boundary}",
          "Content-Length" => body.bytesize.to_s
        },
        body: body
      )

      elapsed = Time.monotonic - time_start

      Log.for("sendPhoto").info { "#{response.status_code} - #{elapsed.total_seconds.humanize(precision: 2, significant: false)}s" }

      Models::Result(Models::Message).from_json(response.body)
    end

    # https://core.telegram.org/bots/api#sendvideo
    def send_video(
      chat_id              : (Int64 | String),
      video                : String,
      duration             : Int64?                 = nil,
      width                : Int64?                 = nil,
      height               : Int64?                 = nil,
      # thumb
      caption              : String?                = nil,
      parse_mode           : (ParseMode | String)?  = nil,
      # caption_entities
      # supports_streaming
      disable_notification : Bool?                  = nil,
      reply_to_message_id  : Int32?                 = nil,
      # allow_sending_without_reply
      reply_markup         : Models::ReplyMarkup?   = nil
    )
      body = {} of String => (Int64 | Int32 | String | Bool | Models::ReplyMarkup)

      body["chat_id"] = chat_id
      body["video"]   = video

      if duration
        body["duration"] = duration
      end

      if width
        body["width"] = width
      end

      if height
        body["height"] = height
      end

      if caption
        body["caption"] = caption
      end

      if parse_mode
        body["parse_mode"] = parse_mode.to_s
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
        "sendVideo",
        Models::Result(Models::Message),
        body: body
      )
    end

    # https://core.telegram.org/bots/api#sendvideo
    def send_video(
      chat_id              : (Int64 | String),
      video                : IO,
      duration             : Int64?                 = nil,
      width                : Int64?                 = nil,
      height               : Int64?                 = nil,
      # thumb
      caption              : String?                = nil,
      parse_mode           : (ParseMode | String)?  = nil,
      # caption_entities
      # supports_streaming
      disable_notification : Bool?                  = nil,
      reply_to_message_id  : Int32?                 = nil,
      # allow_sending_without_reply
      reply_markup         : Models::ReplyMarkup?   = nil
    )
      io = IO::Memory.new

      boundary = @random.hex(20)

      HTTP::FormData.build(io, boundary) do |formdata|
        formdata.field("chat_id", chat_id)

        formdata.file(
          "video",
          photo,
          HTTP::FormData::FileMetadata.new(filename: "video")
        )

        if duration
          formdata.field("duration", duration)
        end

        if width
          formdata.field("width", width)
        end

        if height
          formdata.field("height", height)
        end

        if caption
          formdata.field("caption", caption)
        end

        if parse_mode
          formdata.field("parse_mode", parse_mode.to_s)
        end

        if !disable_notification.nil?
          formdata.field("disable_notification", disable_notification)
        end

        if reply_to_message_id
          formdata.field("reply_to_message_id", reply_to_message_id)
        end

        if reply_markup
          formdata.field("reply_markup", reply_markup.to_json)
        end
      end

      time_start = Time.monotonic

      response = @http_client.post(
        "/bot#{@token}/sendVideo",
        headers: HTTP::Headers{
          "Accept" => "application/json",
          "Content-Type" => "multipart/form-data; boundary=#{boundary}"
        },
        body: io
      )

      elapsed = Time.monotonic - time_start

      Log.for("sendVideo").info { "#{response.status_code} - #{elapsed.total_seconds.humanize(precision: 2, significant: false)}s" }

      Models::Result(Models::Message).from_json(response.body)
    end

    # TODO: Implement media : Array(String | IO)
    # https://core.telegram.org/bots/api#sendmediagroup
    def send_media_group(
      chat_id : (Int64 | String),
      media : Array(String),
      disable_notification : Bool? = nil,
      reply_to_message_id : Int32? = nil,
      allow_sending_without_reply : Bool? = nil
    )
      body = {} of String => (Int64 | String | Array(String) | Bool | Int32)

      body["chat_id"] = chat_id
      body["media"] = media

      if !disable_notification.nil?
        body["disable_notification"] = disable_notification
      end

      if reply_to_message_id
        body["reply_to_message_id"] = reply_to_message_id
      end

      if !allow_sending_without_reply.nil?
        body["allow_sending_without_reply"] = allow_sending_without_reply
      end

      perform_request(
        "sendMediaGroup",
        Models::Result(Array(Models::Message)),
        body: body
      )
    end

    # https://core.telegram.org/bots/api#sendlocation
    def send_location(
      chat_id              : (Int64 | String),
      latitude             : Float64,
      longitude            : Float64,
      live_period          : Int32?               = nil,
      disable_notification : Bool?                = nil,
      reply_to_message_id  : Int32?               = nil,
      reply_markup         : Models::ReplyMarkup? = nil
    )
      body =
        {} of String => (Int64 | Int32 | String | Float64 | Bool | Models::ReplyMarkup)

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
      chat_id              : (Int64 | String),
      phone_number         : String,
      first_name           : String,
      last_name            : String?              = nil,
      vcard                : String?              = nil,
      disable_notification : Bool?                = nil,
      reply_to_message_id	 : Int32?               = nil,
      reply_markup         : Models::ReplyMarkup? = nil
    )
      body = {} of String => (Int64 | Int32 | String | Bool | Models::ReplyMarkup?)

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

    def get_chat_members_count(chat_id : (Int64 | String))
      perform_request(
        "getChatMembersCount",
        Models::Result(Int64),
        body: { chat_id: chat_id }
      )
    end

    def set_my_commands(commands : Array(Models::BotCommand))
      perform_request(
        "setMyCommands",
        body: { commands: commands }
      )
    end

    def get_file(file_id : String)
      perform_request(
        "getFile",
        Models::Result(Models::File),
        body: { file_id: file_id }
      )
    end

    def download_file(file_path : String)
      @http_client.get("/file/bot#{@token}/#{file_path}")
    end

    def download_file(file_path : String, &block : HTTP::Client::Response -> Nil)
      @http_client.get("/file/bot#{@token}/#{file_path}") do |response|
        yield response
      end
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
        headers:
          HTTP::Headers{ "Accept" => "application/json" }.tap do |http_headers|
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

      elapsed = Time.monotonic - time_start

      Log.for(endpoint).info { "#{response.status_code} - #{elapsed.total_seconds.humanize(precision: 2, significant: false)}s" }

      model.from_json(response.body)
    end
  end
end
