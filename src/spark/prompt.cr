require "./prompt/**"

module Spark
  # Spark::Prompt allows you to interact with users to gather input or display messages
  class Prompt
    delegate :print, :puts, to: @output

    # Initialize a new Spark::Prompt
    def initialize(
      @input : IO::FileDescriptor = STDIN,
      @output : IO::FileDescriptor = STDOUT
    )
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
