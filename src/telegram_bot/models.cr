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
        strict: false
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
        strict: false
      )
    end

    # https://core.telegram.org/bots/api#inlinekeyboardmarkup
    class InlineKeyboardMarkup < Base
      JSON.mapping(
        {
          inline_keyboard: Array(Array(InlineKeyboardButton))
        },
        strict: false
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
        strict: false
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
        strict: false
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
        strict: false
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
        strict: false
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
        strict: false
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
        strict: false
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
        strict: false
      )

      def initialize(
        @text             : String,
        @request_contact  : Bool? = nil,
        @request_location : Bool? = nil
      ); end
    end

    # https://core.telegram.org/bots/api#message
    # TODO Implement missing keys
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
          # audio:                   Audio?,
          # document:                Document?,
          # animation:               Animation?,
          # game:                    Game?,
          photo:                   Array(PhotoSize)?,
          # sticker:                 Sticker?,
          # video:                   Video?,
          # voice:                   Voice?,
          # video_note:              VideoNote?,
          caption:                 String?,
          contact:                 Contact?,
          location:                Location?,
          venue:                   Venue?,
          poll:                    Poll?,
          new_chat_members:        Array(User)?,
          left_chat_member:        User?,
          new_chat_title:          String?,
          new_chat_photo:          Array(PhotoSize)?,
          delete_chat_photo:       Bool?,
          group_chat_created:      Bool?,
          supergroup_chat_created: Bool?,
          channel_chat_created:    Bool?,
          migrate_to_chat_id:      Int32?,
          migrate_from_chat_id:    Int32?,
          pinned_message:          Message?,
          invoice:                 Invoice?,
          successful_payment:      SuccessfulPayment?,
          connected_website:       String?,
          # passport_data:           PassportData?,
          reply_markup:            InlineKeyboardMarkup?
        },
        strict: false
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
        strict: false
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
        strict: false
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
          can_pin_messages:          Bool?
        },
        strict: false
      )
    end

    # https://core.telegram.org/bots/api#contact
    class Contact < Base
      JSON.mapping(
        {
          phone_number: String,
          first_name:   String,
          last_name:    String?,
          user_id:      Int32?,
          vcard:        String?
        },
        strict: false
      )
    end


    # https://core.telegram.org/bots/api#location
    class Location < Base
      JSON.mapping(
        {
          latitude:  Float64,
          longitude: Float64
        },
        strict: false
      )
    end

    # https://core.telegram.org/bots/api#venue
    class Venue < Base
      JSON.mapping(
        {
          location:        Location,
          title:           String,
          address:         String,
          foursquare_id:   String?,
          foursquare_type: String?
        },
        strict: false
      )
    end

    # https://core.telegram.org/bots/api#polloption
    class PollOption < Base
      JSON.mapping(
        {
          text:        String,
          voter_count: Int32
        },
        strict: false
      )
    end

    # https://core.telegram.org/bots/api#poll
    class Poll < Base
      JSON.mapping(
        {
          id:        String,
          question:  String,
          options:   Array(PollOption),
          is_closed: Bool
        },
        strict: false
      )
    end

    # https://core.telegram.org/bots/api#invoice
    class Invoice < Base
      JSON.mapping(
        {
          title:           String,
          description:     String,
          start_parameter: String,
          currency:        String,
          total_amount:    Int32
        },
        strict: false
      )
    end

    # https://core.telegram.org/bots/api#shippingaddress
    class ShippingAddress < Base
      JSON.mapping(
        {
          country_code: String,
          state:        String,
          city:         String,
          street_line1: String,
          street_line2: String,
          post_code:    String
        },
        strict: false
      )
    end

    # https://core.telegram.org/bots/api#orderinfo
    class OrderInfo < Base
      JSON.mapping(
        {
          name:             String?,
          phone_number:     String?,
          email:            String?,
          shipping_address: ShippingAddress?
        },
        strict: false
      )
    end

    # https://core.telegram.org/bots/api#successfulpayment
    class SuccessfulPayment < Base
      JSON.mapping(
        {
          currency:                   String,
          total_amount:               Int32,
          invoice_payload:            String,
          shipping_option_id:         String?,
          order_info:                 OrderInfo?,
          telegram_payment_charge_id: String,
          provider_payment_charge_id: String
        },
        strict: false
      )
    end

    # https://core.telegram.org/bots/api#photosize
    class PhotoSize < Base
      JSON.mapping(
        {
          file_id:        String,
          file_unique_id: String,
          width:          Int32,
          height:         Int32,
          file_size:      Int32?
        },
        strict: false
      )
    end

    # https://core.telegram.org/bots/api#inlinequery
    class InlineQuery < Base
      JSON.mapping(
        {
          id:       String,
          from:     User,
          location: Location?,
          query:    String,
          offset:   String
        },
        strict: false
      )
    end

    # https://core.telegram.org/bots/api#choseninlineresult
    class ChosenInlineResult < Base
      JSON.mapping(
        {
          result_id:         String,
          from:              User,
          location:          Location?,
          inline_message_id: String?,
          query:             String,
        },
        strict: false
      )
    end

    # https://core.telegram.org/bots/api#callbackquery
    class CallbackQuery < Base
      JSON.mapping(
        {
          id:                String,
          from:              User,
          message:           Message?,
          inline_message_id: String?,
          chat_instance:     String,
          data:              String?,
          game_short_name:   String?
        },
        strict: false
      )
    end

    # https://core.telegram.org/bots/api#shippingquery
    class ShippingQuery < Base
      JSON.mapping(
        {
          id:               String,
          from:             User,
          invoice_payload:  String,
          shipping_address: ShippingAddress
        },
        strict: false
      )
    end

    # https://core.telegram.org/bots/api#precheckoutquery
    class PreCheckoutQuery < Base
      JSON.mapping(
        {
          id:                 String,
          from:               User,
          currency:           String,
          total_amount:       Int32,
          invoice_payload:    String,
          shipping_option_id: String?,
          order_info:         OrderInfo?
        },
        strict: false
      )
    end

    # https://core.telegram.org/bots/api#update
    class Update < Base
      JSON.mapping(
        {
          update_id:            Int32,
          message:              Message?,
          edited_message:       Message?,
          channel_post:         Message?,
          edited_channel_post:  Message?,
          inline_query:         InlineQuery?,
          chosen_inline_result: ChosenInlineResult?,
          callback_query:       CallbackQuery?,
          shipping_query:       ShippingQuery?,
          pre_checkout_query:   PreCheckoutQuery?,
          poll:                 Poll?
        },
        strict: false
      )
    end
  end
end
