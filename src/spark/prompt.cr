require "./prompt/*"

module Spark
  # Spark::Prompt allows you to interact with users to gather input or display messages
  class Prompt
    delegate :print, :puts, to: @output
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
    # prompt.yes?("Are you sure?") # => "Are you sure? [Y/n]"
    # # => "Yes"
    # # => true
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
    # prompt.no?("Are you sure?") # => "Are you sure? [y/N]"
    # # => "No"
    # # => true
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
    def decorate(string : String, color : Symbol | Nil = nil, style : Symbol | Nil = nil)
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
  end
end
