module Spark
  class Prompt
    # A Question is used to gather user input.
    class Question
      getter color
      getter style
      getter default

      def initialize(
        @prompt : Spark::Prompt,
        @color : Symbol | Nil = nil,
        @style : Symbol | Nil = nil,
        @default : Bool | String | Nil = nil,
        **options
      )
      end

      def call(message : String)
        message = add_default_to_message(message)
        message = message + " "
        message = @prompt.decorate(message, color, style)
        @prompt.print message

        input = @prompt.gets

        process_input(input)
      end

      # For any given question, if a non-blank string is provided, that is the answer.
      #
      # If `nil` or a blank string is provided, we use the default.
      private def process_input(input : String?)
        if (valid_string = input) && !valid_string.blank?
          valid_string
        else
          default
        end
      end

      private def add_default_to_message(message : String)
        case default
        when Bool
          if default == true
            message + " [Y/n]"
          else
            message + " [y/N]"
          end
        when String
          message + " [#{default}]"
        else
          message
        end
      end
    end
  end
end
