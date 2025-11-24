module Spark
  class Prompt
    # A Question is used to gather user input.
    class Question(AnswerType, DefaultAnswerType)
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

      # Creates a new Question.
      def initialize(
        @prompt : Spark::Prompt,
        @color : Symbol? = nil,
        @style : Symbol? = nil,
        @default : DefaultAnswerType? = nil,
        **options,
      )
      end

      # Ask the question to the user.
      #
      # This handles adding the default text, a space before user input, and decoration.
      #
      # It also gathers user input.
      def call(message : String) : AnswerType?
        message = add_default_to_message(message)
        message = message + " "
        message = @prompt.decorate(message, color, style)
        @prompt.print message

        input = @prompt.gets

        process_input(input)
      end

      # Ask the question to the user, including a block with additional settings.
      #
      # We optionally allow the ability to re-collect invalid input.
      #
      # If `@retry_on_validation_failure` is `true` (set via `#validate`), we collect input until it is valid.
      # If `@retry_on_validation_failure` is `false` (set via `#validate`), we collect input once and return `nil` if it is invalid.
      def call(message : String, &)
        message = add_default_to_message(message)
        message = message + " "
        message = @prompt.decorate(message, color, style)

        yield(self)

        input = collect_input_for(message)

        while !valid_input?(input)
          print_validation_error_message

          if @retry_on_validation_failure
            input = collect_input_for(message)
          else
            input = nil
            break
          end
        end

        process_input(input)
      end

      # Provide validation for a `Spark::Prompt::Question`, optionally overriding the default error message.
      #
      # Example with the default message:
      # ```
      # Question.new(Spark::Prompt.new).call("What is your name") do |question|
      #   question.validate(/LuckyCasts/)
      # end
      # # => "What is your name?"
      # ```
      #
      # Example with a custom message:
      # ```
      # Question.new(Spark::Prompt.new).call("What is your name") do |question|
      #   question.validate(/LuckyCasts/, "Your name must be 'LuckyCasts'")
      # end
      # # => "What is your name?"
      # ```
      #
      # Example that retries on validation failure:
      # ```
      # Question.new(Spark::Prompt.new).call("What is your name") do |question|
      #   question.validate(/LuckyCasts/, "Your name must be 'LuckyCasts'. Please enter a valid value.", retry_on_failure: true)
      # end
      # # => "What is your name?"
      # ```
      def validate(@validation : Regex, error_message : String? = nil, *, retry_on_failure : Bool = false)
        @retry_on_validation_failure = retry_on_failure

        if message = error_message
          @validation_error_message = message
        else
          @validation_error_message = "Your answer does not match '#{validation.inspect}'"
        end
      end

      # Output the validation error defined in `#validate` to the user.
      private def print_validation_error_message
        return unless error_message = @validation_error_message

        Spark.logger.log_action("Invalid input", error_message, color: :light_red)
      end

      # Collect input from the user.
      private def collect_input_for(message : Colorize::Object(String)) : String?
        @prompt.print message
        @prompt.gets
      end

      # Validate some user input against an optional, previously-defined `@validation` `Regex`.
      #
      # If the validation fails, print out the appropriate error message to the user.
      private def valid_input?(input : String?) : Bool
        return true unless validation = @validation

        unless validation.matches?(input.to_s)
          return false
        end

        true
      end

      # For any given question, if a non-blank string is provided, that is the answer.
      #
      # If `nil` or a blank string is provided, we use the default.
      #
      # All leading/trailing whitespace is also removed from Strings.
      private def process_input(input : String?)
        if (valid_string = input) && !valid_string.blank?
          valid_string.strip
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
