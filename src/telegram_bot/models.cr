require "json"

module TelegramBot
  # TODO: Sort models as done in API docs
  module Models
    abstract class Base
      include JSON::Serializable
    end

    alias ReplyMarkup = (InlineKeyboardMarkup | ReplyKeyboardMarkup | ReplyKeyboardRemove | ForceReply)

    class Result(T) < Base
      property ok : Bool
      property result : T?
      property description : String?
      property error_code : Int32?
    end

    # https://core.telegram.org/bots/api#webhookinfo
    class WebhookInfo < Base
      property url                    : String
      property has_custom_certificate : Bool
      property pending_update_count   : Int32
      property last_error_date        : Int32?
      property last_error_message     : String?
      property max_connections        : Int32?
      property allowed_updates        : Array(String)?
    end

    # https://core.telegram.org/bots/api#inlinekeyboardmarkup
    class InlineKeyboardMarkup < Base
      property inline_keyboard : Array(Array(InlineKeyboardButton))

      def initialize(@inline_keyboard : Array(Array(InlineKeyboardButton))); end
    end

    # https://core.telegram.org/bots/api#replykeyboardmarkup
    class ReplyKeyboardMarkup < Base
      property keyboard          : Array(Array(KeyboardButton))
      property resize_keyboard   : Bool?
      property one_time_keyboard : Bool?
      property selective         : Bool?

      def initialize(
        @keyboard          : Array(Array(KeyboardButton)),
        @resize_keyboard   : Bool? = nil,
        @one_time_keyboard : Bool? = nil,
        @selective         : Bool? = nil
      ); end
    end

    # https://core.telegram.org/bots/api#inlinekeyboardbutton
    class InlineKeyboardButton < Base
      property text                             : String
      property url                              : String?
      property login_url                        : LoginUrl?
      property callback_data                    : String?
      property switch_inline_query              : String?
      property switch_inline_query_current_chat : String?
      property callback_game                    : CallbackGame?
      property pay                              : Bool?

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
      property remove_keyboard : Bool
      property selective     : Bool?

      def initialize(
        @remove_keyboard : Bool  = true,
        @selective       : Bool? = nil
      ); end
    end

    # https://core.telegram.org/bots/api#forcereply
    class ForceReply < Base
      property force_reply : Bool
      property selective   : Bool?

      def initialize(
        @force_reply : Bool,
        @selective   : Bool? = nil
      ); end
    end

    # https://core.telegram.org/bots/api#loginurl
    class LoginUrl < Base
      property url                  : String
      property forward_text         : String?
      property bot_username         : String?
      property request_write_access : Bool?

      def initialize(
        @url                  : String,
        @forward_text         : String? = nil,
        @bot_username         : String? = nil,
        @request_write_access : Bool?   = nil
      ); end
    end

    # https://core.telegram.org/bots/api#callbackgame
    class CallbackGame < Base
      property user_id              : Int32
      property score                : Int32
      property force                : Bool?
      property disable_edit_message : Bool?
      property chat_id              : Int64?
      property message_id           : Int32?
      property inline_message_id    : String?

      def initialize(
        @user_id              : Int32,
        @score                : Int32,
        @force                : Bool?   = nil,
        @disable_edit_message : Bool?   = nil,
        @chat_id              : Int64?  = nil,
        @message_id           : Int32?  = nil,
        @inline_message_id    : String? = nil
      ); end
    end

    # https://core.telegram.org/bots/api#keyboardbutton
    class KeyboardButton < Base
      property text             : String
      property request_contact  : Bool?
      property request_location : Bool?

      def initialize(
        @text             : String,
        @request_contact  : Bool? = nil,
        @request_location : Bool? = nil
      ); end
    end

    # https://core.telegram.org/bots/api#message
    # TODO Implement missing keys
    class Message < Base
      property message_id              : Int32
      property from                    : User?
      property date                    : Int32
      property chat                    : Chat
      property forward_from            : User?
      property forward_from_chat       : Chat?
      property forward_from_message_id : Int32?
      property forward_signature       : String?
      property forward_sender_name     : String?
      property forward_date            : Int32?
      property reply_to_message        : Message?
      property edit_date               : Int32?
      property media_group_id          : String?
      property author_signature        : String?
      property text                    : String?
      property entities                : Array(MessageEntity)?
      property caption_entities        : Array(MessageEntity)?
      # property audio                   : Audio?
      # property document                : Document?
      # property animation               : Animation?
      # property game                    : Game?
      property photo                   : Array(PhotoSize)?
      # property sticker                 : Sticker?
      property video                   : Video?
      # property voice                   : Voice?
      # property video_note              : VideoNote?
      property caption                 : String?
      property contact                 : Contact?
      property location                : Location?
      property venue                   : Venue?
      property poll                    : Poll?
      property new_chat_members        : Array(User)?
      property left_chat_member        : User?
      property new_chat_title          : String?
      property new_chat_photo          : Array(PhotoSize)?
      property delete_chat_photo       : Bool?
      property group_chat_created      : Bool?
      property supergroup_chat_created : Bool?
      property channel_chat_created    : Bool?
      property migrate_to_chat_id      : Int64?
      property migrate_from_chat_id    : Int64?
      property pinned_message          : Message?
      property invoice                 : Invoice?
      property successful_payment      : SuccessfulPayment?
      property connected_website       : String?
      # property passport_data           : PassportData?
      property reply_markup            : InlineKeyboardMarkup?
    end

    # https://core.telegram.org/bots/api#messageentity
    class MessageEntity < Base
      property type   : String
      property offset : Int32
      property length : Int32
      property url    : String?
      property user   : User?
    end

    # https://core.telegram.org/bots/api#user
    class User < Base
      property id            : Int32
      property is_bot        : Bool
      property first_name    : String
      property last_name     : String?
      property username      : String?
      property language_code : String?
    end

    # https://core.telegram.org/bots/api#chat
    class Chat < Base
      property id                  : Int64
      property type                : String
      property title               : String?
      property username            : String?
      property first_name          : String?
      property last_name           : String?
      property photo               : ChatPhoto?
      property description         : String?
      property invite_link         : String?
      property pinned_message      : Message?
      property permissions         : ChatPermissions?
      property slow_mode_delay     : Int32?
      property sticker_set_name    : String?
      property can_set_sticker_set : Bool?
    end

    # https://core.telegram.org/bots/api#chatphoto
    class ChatPhoto < Base
      property small_file_id        : String
      property small_file_unique_id : String
      property big_file_id          : String
      property big_file_unique_id   : String
    end

    # https://core.telegram.org/bots/api#chatpermissions
    class ChatPermissions < Base
      property can_send_messages         : Bool?
      property can_send_media_messages   : Bool?
      property can_send_polls            : Bool?
      property can_send_other_messages   : Bool?
      property can_add_web_page_previews : Bool?
      property can_change_info           : Bool?
      property can_invite_users          : Bool?
      property can_pin_messages          : Bool?
    end

    # https://core.telegram.org/bots/api#contact
    class Contact < Base
      property phone_number : String
      property first_name   : String
      property last_name    : String?
      property user_id      : Int32?
      property vcard        : String?
    end


    # https://core.telegram.org/bots/api#location
    class Location < Base
      property latitude  : Float64
      property longitude : Float64
    end

    # https://core.telegram.org/bots/api#venue
    class Venue < Base
      property location        : Location
      property title           : String
      property address         : String
      property foursquare_id   : String?
      property foursquare_type : String?
    end

    # https://core.telegram.org/bots/api#polloption
    class PollOption < Base
      property text        : String
      property voter_count : Int32
    end

    # https://core.telegram.org/bots/api#poll
    class Poll < Base
      property id        : String
      property question  : String
      property options   : Array(PollOption)
      property is_closed : Bool
    end

    # https://core.telegram.org/bots/api#invoice
    class Invoice < Base
      property title           : String
      property description     : String
      property start_parameter : String
      property currency        : String
      property total_amount    : Int32
    end

    # https://core.telegram.org/bots/api#shippingaddress
    class ShippingAddress < Base
      property country_code : String
      property state        : String
      property city         : String
      property street_line1 : String
      property street_line2 : String
      property post_code    : String
    end

    # https://core.telegram.org/bots/api#orderinfo
    class OrderInfo < Base
      property name             : String?
      property phone_number     : String?
      property email            : String?
      property shipping_address : ShippingAddress?
    end

    # https://core.telegram.org/bots/api#successfulpayment
    class SuccessfulPayment < Base
      property currency                   : String
      property total_amount               : Int32
      property invoice_payload            : String
      property shipping_option_id         : String?
      property order_info                 : OrderInfo?
      property telegram_payment_charge_id : String
      property provider_payment_charge_id : String
    end

    # https://core.telegram.org/bots/api#photosize
    class PhotoSize < Base
      property file_id        : String
      property file_unique_id : String
      property width          : Int32
      property height         : Int32
      property file_size      : Int32?
    end

    # https://core.telegram.org/bots/api#inlinequery
    class InlineQuery < Base
      property id       : String
      property from     : User
      property location : Location?
      property query    : String
      property offset   : String
    end

    # https://core.telegram.org/bots/api#choseninlineresult
    class ChosenInlineResult < Base
      property result_id         : String
      property from              : User
      property location          : Location?
      property inline_message_id : String?
      property query             : String
    end

    # https://core.telegram.org/bots/api#callbackquery
    class CallbackQuery < Base
      property id                : String
      property from              : User
      property message           : Message?
      property inline_message_id : String?
      property chat_instance     : String
      property data              : String?
      property game_short_name   : String?
    end

    # https://core.telegram.org/bots/api#shippingquery
    class ShippingQuery < Base
      property id               : String
      property from             : User
      property invoice_payload  : String
      property shipping_address : ShippingAddress
    end

    # https://core.telegram.org/bots/api#precheckoutquery
    class PreCheckoutQuery < Base
      property id                 : String
      property from               : User
      property currency           : String
      property total_amount       : Int32
      property invoice_payload    : String
      property shipping_option_id : String?
      property order_info         : OrderInfo?
    end

    # https://core.telegram.org/bots/api#update
    class Update < Base
      property update_id            : Int32
      property message              : Message?
      property edited_message       : Message?
      property channel_post         : Message?
      property edited_channel_post  : Message?
      property inline_query         : InlineQuery?
      property chosen_inline_result : ChosenInlineResult?
      property callback_query       : CallbackQuery?
      property shipping_query       : ShippingQuery?
      property pre_checkout_query   : PreCheckoutQuery?
      property poll                 : Poll?
    end

    # https://core.telegram.org/bots/api#file
    class File < Base
      property file_id : String
      property file_unique_id : String
      property file_size : Int32?
      property file_path : String?
    end

    # https://core.telegram.org/bots/api#video
    class Video < Base
      property file_id : String
      property file_unique_id : String
      property width : Int64
      property height : Int64
      property duration : Int64
      property thumb : PhotoSize?
      property file_name : String?
      property mime_type : String?
      property file_size : Int64?
    end

    abstract class InputMedia < Base
      property type : String
      property media : String
      property caption : String?
      property parse_mode : (ParseMode | String)?
      property caption_entities : Array(MessageEntity)?

      def initialize(
        @type : String,
        @media : String,
        @caption : String? = nil,
        @parse_mode : (ParseMode | String)? = nil,
        @caption_entities : Array(MessageEntity)? = nil
      )
      end
    end

    # https://core.telegram.org/bots/api#inputmediaphoto
    class InputMediaPhoto < InputMedia
      def initialize(
        media : String,
        caption : String? = nil,
        parse_mode : (ParseMode | String)? = nil,
        caption_entities : Array(MessageEntity)? = nil
      )
        super("photo", media, caption, parse_mode, caption_entities)
      end
    end

    # https://core.telegram.org/bots/api#inputmediavideo
    class InputMediaVideo < InputMedia
      property thumb : String? # TODO: Implement thumb being an IO
      property width : Int64?
      property height : Int64?
      property duration : Int64?
      property supports_streaming : Bool?

      def initialize(
        media : String,
        caption : String? = nil,
        parse_mode : (ParseMode | String)? = nil,
        caption_entities : Array(MessageEntity)? = nil,
        @thumb : String? = nil,
        @width : Int64? = nil,
        @height : Int64? = nil,
        @duration : Int64? = nil,
        @supports_streaming : Bool? = nil
      )
        super("video", media, caption, parse_mode, caption_entities)
      end
    end

    class BotCommand < Base
      property command     : String
      property description : String

      def initialize(@command : String, @description : String); end
    end
  end
end
