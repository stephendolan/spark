require "./prompt/*"

module Spark
  # Spark::Prompt allows you to interact with users to gather input or display messages
  class Prompt
    # :nodoc:
    #
    # These delegations are mainly used for testing with File-based input/output,
    # but could certainly be leveraged by end users as well.
    delegate :print, :puts, to: @output

    # :nodoc:
    #
    # These delegations are mainly used for testing with File-based input/output,
    # but could certainly be leveraged by end users as well.
    delegate :gets, to: @input

    # Initialize a new Spark::Prompt
    def initialize(@input : IO::FileDescriptor = STDIN, @output : IO::FileDescriptor = STDOUT)
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

    # Ask the user a question.
    #
    # Example:
    # ```
    # prompt = Spark::Prompt.new
    # prompt.ask("What is your name?") # => "What is your name?"
    # ```
    def ask(message : String, **options)
      return if message.blank?

      question = Question.new(self, **options)
      question.call(message)
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
    def yes?(message : String, **options)
      return if message.blank?

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
    def no?(message : String, **options)
      return if message.blank?

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
      string = case color
               in Symbol
                 string.colorize(color)
               in Nil
                 string.colorize(:default)
               end

      case style
      in Symbol
        string.mode(style)
      in Nil
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

      options_with_default_bolding = options.merge(style: :bold)
      action = decorate(action, **options_with_default_bolding)
      message = [action, message].compact.join(" -- ")

      Statement.new(self).call(message)
    end
  end
end
