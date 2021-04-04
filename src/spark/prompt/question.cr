module Spark
  class Prompt
    # A Question is used to gather user input.
    class Question
      getter color
      getter style
      getter default

      # Creates a new Question.
      def initialize(
        @prompt : Spark::Prompt,
        @color : Symbol | Nil = nil,
        @style : Symbol | Nil = nil,
        @default : Bool | String | Nil = nil,
        **options
      )
      end

      # Ask the question to the user.
      #
      # This handles adding the default text, a space before user input, and decoration.
      #
      # It also gathers user input.
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

      # If a default is provided, we add the default to the end of the question in square brackets ("[ ]")
      #
      # Example:
      # ```
      # prompt = Spark::Prompt.new
      # prompt.ask "What is your name?", default: "LuckyCasts"
      # # => What is your name? [LuckyCasts]
      # ```
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
