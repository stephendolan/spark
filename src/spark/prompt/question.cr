module Spark
  class Prompt
    # A Question is used to gather user input.
    class Question
      getter color
      getter style

      def initialize(
        @prompt : Spark::Prompt,
        @color : Symbol | Nil = nil,
        @style : Symbol | Nil = nil
      )
      end

      def call(message : String)
        message = message + " " * 1
        message = @prompt.decorate(message, color, style)
        @prompt.print message

        @prompt.gets
      end
    end
  end
end
