require "json"

module TelegramBot
  # TODO: Sort models as done in API docs
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
        @remove_keyboard : Bool  = true,
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
        @request_write_access : Bool?   = nil
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
    class Message < Base
      JSON.mapping(
        {
          message_id:              Int32,
          from:                    User?,
          date:                    Int32,
          chat:                    Chat,
          forward_from:            User?,
          forward_from_chat:       Chat?,
          forward_from_message_id: Int32?,
          forward_signature:       String?,
          forward_sender_name:     String?,
          forward_date:            Int32?,
          reply_to_message:        Message?,
          edit_date:               Int32?,
          media_group_id:          String?,
          author_signature:        String?,
          text:                    String?,
          entities:                Array(MessageEntity)?,
          caption_entities:        Array(MessageEntity)?,
        },
        strict: true
      )
    end

    # https://core.telegram.org/bots/api#messageentity
    class MessageEntity < Base
      JSON.mapping(
        {
          type:   String,
          offset: Int32,
          length: Int32,
          url:    String?,
          user:   User?
        },
        strict: true
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
        strict: true
      )
    end

    # https://core.telegram.org/bots/api#chat
    class Chat < Base
      JSON.mapping(
        {
          id:                  Int32,
          type:                String,
          title:               String?,
          username:            String?,
          first_name:          String?,
          last_name:           String?,
          photo:               ChatPhoto?,
          description:         String?,
          invite_link:         String?,
          pinned_message:      Message?,
          permissions:         ChatPermissions?,
          slow_mode_delay:     Int32?,
          sticker_set_name:    String?,
          can_set_sticker_set: Bool?
        },
        strict: true
      )
    end

    # https://core.telegram.org/bots/api#chatphoto
    class ChatPhoto < Base
      JSON.mapping(
        {
          small_file_id:        String,
          small_file_unique_id: String,
          big_file_id:          String,
          big_file_unique_id:   String
        },
        strict: true
      )
    end

    # https://core.telegram.org/bots/api#chatpermissions
    class ChatPermissions < Base
      JSON.mapping(
        {
          can_send_messages:         Bool?,
          can_send_media_messages:   Bool?,
          can_send_polls:            Bool?,
          can_send_other_messages:   Bool?,
          can_add_web_page_previews: Bool?,
          can_change_info:           Bool?,
          can_invite_users:          Bool?,
          can_pin_messages:          Bool?,
        },
        strict: true
      )
    end
  end
end
