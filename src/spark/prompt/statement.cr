module Spark
  class Prompt
    # Represents a statement output to the user's prompt.
    class Statement
      getter? newline
      getter color
      getter style

      # Create a new Statement that can be rendered as output to the user's prompt.
      def initialize(
        @prompt : Spark::Prompt,
        @newline : Bool = true,
        @color : Symbol = :default,
        @style : Symbol | Nil = nil
      )
      end

      # Output the Statement message to the prompt
      def call(message : String)
        message = @prompt.decorate(message, color, style)

        if newline?
          @prompt.puts message
        else
          @prompt.print message
        end
      end
    end
  end
end
