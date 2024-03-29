require "./prompt/*"

require "colorize"

module Spark
  # Spark::Prompt allows you to interact with users to gather input or display messages
  class Prompt
    # :nodoc:
    #
    # These delegations are mainly used for testing with File-based input/output,
    # but could certainly be leveraged by end users as well.
    delegate :gets, to: @input

    # Initialize a new Spark::Prompt
    def initialize(@input : IO::FileDescriptor = STDIN, @output : IO::FileDescriptor = STDOUT)
    end

    # :nodoc:
    #
    # Provides a simple method delegation to add indentation to the front of all output.
    def print(*objects : _) : Nil
      @output.print("\t" * Spark.indent_level)
      @output.print(*objects)
    end

    # :nodoc:
    #
    # Provides a simple method delegation to add indentation to the front of all output.
    def puts(*objects : _) : Nil
      @output.print("\t" * Spark.indent_level)
      @output.puts(*objects)
    end

    # Output some text to a user, with an optional color and style.
    #
    # Plain example:
    # ```
    # prompt = Spark::Prompt.new
    # prompt.say("This is an example") # => "This is an example\n"
    # ```
    #
    # Without a newline:
    # ```
    # prompt = Spark::Prompt.new
    # prompt.say("This is an example", newline: false) # => "This is an example"
    # ```
    #
    # With color and style (see Spark::Prompt#decorate):
    # ```
    # prompt = Spark::Prompt.new
    # prompt.say("This is an example", color: :green, style: :bold) # => "\e[32;1mHello, there!\e[0m\n"
    # ```
    def say(message : String = "", **options)
      return if message.blank?

      statement = Statement.new(self, **options)
      statement.call(message)
    end

    # Output an empty line to the user's prompt.
    #
    # Example:
    # ```
    # prompt = Spark::Prompt.new
    # prompt.say("This is an example") # => "This is an example\n"
    # prompt.newline                   # => "\n"
    # ```
    def newline
      Statement.new(self).call("")
    end

    # Ask the user a question.
    #
    # Example:
    # ```
    # prompt = Spark::Prompt.new
    # prompt.ask("What is your name?") # => "What is your name?"
    # ```
    def ask(message : String, **options) : String
      return "" if message.blank?

      question = Question(String, String).new(self, **options)
      question.call(message).to_s
    end

    # Ask the user a question with optional validation.
    #
    # Example with validation:
    # ```
    # prompt = Spark::Prompt.new
    # prompt.ask("What is your name?") do |question|
    #   question.validate(/LuckyCasts/, error_message: "Name must be 'LuckyCasts'")
    # end
    # # => "What is your name?"
    # ```
    def ask(message : String, **options, &block : Spark::Prompt::Question(String, String) -> _) : String
      return "" if message.blank?

      question = Question(String, String).new(self, **options)
      question.call(message, &block).to_s
    end

    # Ask the user a yes/no question, where the default is "Yes".
    #
    # Example:
    # ```
    # prompt = Spark::Prompt.new
    # if prompt.yes? "Did you tell me the truth?"
    #   prompt.say "Great! Thank you, #{user_name}.", color: :green
    # else
    #   prompt.say "Shame on you!"
    # end
    # ```
    def yes?(message : String, **options) : Bool
      return false if message.blank?

      options_with_default = options.merge(default: true)
      question = ConfirmationQuestion.new(self, **options_with_default)
      question.call(message)
    end

    # Ask the user a yes/no question, where the default is "No".
    #
    # Example:
    # ```
    # prompt = Spark::Prompt.new
    # if prompt.no? "Are you feeling happy today?"
    #   prompt.say "I'm sorry to hear that."
    # else
    #   prompt.say "Then it's going to be a great day!"
    # end
    # ```
    def no?(message : String, **options) : Bool
      return false if message.blank?

      options_with_default = options.merge(default: false)
      question = ConfirmationQuestion.new(self, **options_with_default)
      question.call(message)
    end

    # Color and stylize a given string.
    #
    # Example:
    # ```
    # prompt = Spark::Prompt.new
    # prompt.decorate("This is an example", color: :green, style: :bold) # => "\e[32;1mHello, there!\e[0m\n"
    # ```
    def decorate(string : String, color : Symbol? = nil, style : Symbol? = nil)
      string = if (color = Colorize::ColorANSI.parse?(color.to_s))
                 string.colorize(color)
               else
                 string.colorize(:default)
               end

      if (style = Colorize::Mode.parse?(style.to_s))
        string.mode(style)
      else
        string
      end
    end

    # :nodoc:
    #
    # Print a colorized action and plain message to the user.
    #
    # This is mainly for internal use by other `Spark` modules.
    #
    # Example:
    # ```
    # prompt = Spark::Prompt.new
    # prompt.log_action("COMPILING", "src/start_server.cr", color: :yellow)
    # prompt.log_action("DONE", color: :green)
    # ```
    def log_action(action : String, message : String? = nil, **options)
      return if Spark.quiet?

      action = decorate(action, **options)
      message = [action, message].compact.join(" -- ")

      # Always indent log messages one additional level for prettier output.
      message = "\t" + message

      Statement.new(self).call(message)
    end
  end
end
