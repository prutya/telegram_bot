require "http/client"
require "json"
require "logger"
require "uri"

module TelegramBot
  VERSION = "0.1.0"

  module Models
    abstract class Base; end

    alias ReplyMarkup = (InlineKeyboardMarkup | ReplyKeyboardMarkup | ReplyKeyboardRemove | ForceReply)

    class Result(T) < Base
      JSON.mapping(
        {
          ok:          Bool,
          result:      T?,
          description: String?,
          error_code:  Int32?,
        },
        strict: true
      )
    end

    # https://core.telegram.org/bots/api#webhookinfo
    class WebhookInfo < Base
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

    # https://core.telegram.org/bots/api#inlinekeyboardmarkup
    class InlineKeyboardMarkup < Base
      JSON.mapping(
        {
          inline_keyboard: Array(Array(InlineKeyboardButton))
        },
        strict: true
      )

      def initialize(@inline_keyboard : Array(Array(InlineKeyboardButton))); end
    end

    # https://core.telegram.org/bots/api#replykeyboardmarkup
    class ReplyKeyboardMarkup < Base
      JSON.mapping(
        {
          keyboard:          Array(Array(KeyboardButton)),
          resize_keyboard:   Bool?,
          one_time_keyboard: Bool?,
          selective:         Bool?
        },
        strict: true
      )

      def initialize(
        @keyboard          : Array(Array(KeyboardButton)),
        @resize_keyboard   : Bool? = nil,
        @one_time_keyboard : Bool? = nil,
        @selective         : Bool? = nil
      ); end
    end

    # https://core.telegram.org/bots/api#inlinekeyboardbutton
    class InlineKeyboardButton < Base
      JSON.mapping(
        {
          text:                             String,
          url:                              String?,
          login_url:                        LoginUrl?,
          callback_data:                    String?,
          switch_inline_query:              String?,
          switch_inline_query_current_chat: String?,
          callback_game:                    CallbackGame?,
          pay:                              Bool?
        },
        strict: true
      )

      def initialize(
        @text                             : String,
        @url                              : String?       = nil,
        @login_url                        : LoginUrl?     = nil,
        @callback_data                    : String?       = nil,
        @switch_inline_query              : String?       = nil,
        @switch_inline_query_current_chat : String?       = nil,
        @callback_game                    : CallbackGame? = nil,
        @pay                              : Bool?         = nil
      ); end
    end

    # https://core.telegram.org/bots/api#replykeyboardremove
    class ReplyKeyboardRemove < Base
      JSON.mapping(
        {
          remove_keyboard: Bool,
          selective:       Bool?
        },
        strict: true
      )

      def initialize(
        @remove_keyboard : Bool,
        @selective       : Bool? = nil
      ); end
    end

    # https://core.telegram.org/bots/api#forcereply
    class ForceReply < Base
      JSON.mapping(
        {
          force_reply: Bool,
          selective:   Bool?
        },
        strict: true
      )

      def initialize(
        @force_reply : Bool,
        @selective   : Bool? = nil
      ); end
    end

    # https://core.telegram.org/bots/api#loginurl
    class LoginUrl < Base
      JSON.mapping(
        {
          url:                  String,
          forward_text:         String?,
          bot_username:         String?,
          request_write_access: Bool?
        },
        strict: true
      )

      def initialize(
        @url                  : String,
        @forward_text         : String? = nil,
        @bot_username         : String? = nil,
        @request_write_access : Bool? = nil
      ); end
    end

    # https://core.telegram.org/bots/api#callbackgame
    class CallbackGame < Base
      JSON.mapping(
        {
          user_id:              Int32,
          score:                Int32,
          force:                Bool?,
          disable_edit_message: Bool?,
          chat_id:              Int32?,
          message_id:           Int32?,
          inline_message_id:    String?
        },
        strict: true
      )

      def initialize(
        @user_id              : Int32,
        @score                : Int32,
        @force                : Bool?   = nil,
        @disable_edit_message : Bool?   = nil,
        @chat_id              : Int32?  = nil,
        @message_id           : Int32?  = nil,
        @inline_message_id    : String? = nil
      ); end
    end

    # https://core.telegram.org/bots/api#keyboardbutton
    class KeyboardButton < Base
      JSON.mapping(
        {
          text:             String,
          request_contact:  Bool?,
          request_location: Bool?,
        },
        strict: true
      )

      def initialize(
        @text             : String,
        @request_contact  : Bool? = nil,
        @request_location : Bool? = nil
      ); end
    end

    # https://core.telegram.org/bots/api#message
    # TODO: Not complete list of fields
    class Message < Base
      JSON.mapping(
        {
          message_id: Int32,
          from: User?,
          date: Int32,
          chat: Chat,
          forward_from: User?,
          forward_from_chat: Chat?,
          forward_from_message_id: Int32?,
          forward_signature: String?,
          forward_sender_name: String?,
          forward_date: Int32?,
          # reply_to_message: Message?,
          edit_date: Int32?,
          media_group_id: String?,
          author_signature: String?,
          text: String?,
          # entities: Array(MessageEntity)?,
          # caption_entities: Array(MessageEntity)?,
        },
        strict: false
      )
    end

    # https://core.telegram.org/bots/api#user
    class User < Base
      JSON.mapping(
        {
          id:            Int32,
          is_bot:        Bool,
          first_name:    String,
          last_name:     String?,
          username:      String?,
          language_code: String?
        },
        strict: false
      )
    end

    # https://core.telegram.org/bots/api#chat
    # TODO: Not complete list of fields
    class Chat < Base
      JSON.mapping(
        {
          id:    Int32,
          type:  String,
          title: String?,
          username: String?,
          first_name: String?,
          last_name:  String?,
          # photo: ChatPhoto?,
          description: String?,
          invite_link: String?,
          pinned_message: Message?,
          # permissions: ChatPermissions?,
          slow_mode_delay: Int32?,
          sticker_set_name: String?,
          can_set_sticker_set: Bool?
        },
        strict: false
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
    def set_webhook(
      url             : String,
      # certificate : InputFile
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
      body = {} of String => (Int32 | String | Bool | Models::ReplyMarkup | Nil)

      body["chat_id"] = chat_id
      body["text"]    = text

      if parse_mode
        body["parse_mode"] = parse_mode
      end

      if disable_web_page_preview
        body["disable_web_page_preview"] = disable_web_page_preview
      end

      if disable_notification
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
