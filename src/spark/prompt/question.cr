module Spark
  class Prompt
    # A Question is used to gather user input.
    class Question
      # Which color to use to colorize the Question output.
      #
      # See https://crystal-lang.org/api/latest/Colorize.html
      #
      # Example:
      # ```
      # :default
      # :black
      # :red
      # :green
      # :yellow
      # :blue
      # ```
      getter color

      # Which mode to use to stylize the Question output.
      #
      # See https://crystal-lang.org/api/latest/Colorize.html
      #
      # Example:
      # ```
      # :bold
      # :bright
      # :dim
      # :underline
      # :blink
      # :reverse
      # :hidden
      # ```
      getter style

      # Which default value to use for a blank/empty response to the Question.
      getter default

      # The `Regex` to use to validate the response to the Question.
      getter validation : Regex?

      # The message to display if the `#validation` does not match the response to the Question.
      getter validation_error_message : String?

      # Creates a new Question.
      def initialize(
        @prompt : Spark::Prompt,
        @color : Symbol? = nil,
        @style : Symbol? = nil,
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

      # Ask the question to the user, including a block with additional settings.
      #
      # This handles adding the default text, a space before user input, and decoration.
      #
      # It also gathers user input.
      def call(message : String, &)
        message = add_default_to_message(message)
        message = message + " "
        message = @prompt.decorate(message, color, style)

        yield(self)

        @prompt.print message

        input = @prompt.gets

        input = validate_input(input)
        process_input(input)
      end

      def validate(@validation : Regex, error_message : String? = nil)
        if (message = error_message)
          @validation_error_message = message
        else
          @validation_error_message = "Your answer does not match '#{validation.inspect}'"
        end
      end

      private def validate_input(input : String?)
        if (validation_pattern = validation) && (response = input)
          unless validation_pattern.matches?(response)
            if (error_message = validation_error_message)
              error_message = @prompt.decorate(error_message, color: :red)
              @prompt.puts
              @prompt.puts(error_message)
            end

            return nil
          end
        end

        input
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
