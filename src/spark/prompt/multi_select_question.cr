require "./question"

module Spark
  class Prompt
    class MultiSelectQuestion < Question
      getter choices

      # Creates a new Select Question with options.
      def initialize(
        @prompt : Spark::Prompt,
        @choices : Array(String),
        @color : Symbol? = nil,
        @style : Symbol? = nil,
        @default : String? | Array(String)? = nil,
        **options
      )
        if @choices.empty?
          raise ArgumentError.new("Must supply at least one choice for a Select question")
        end

        if (provided_default = @default).is_a?(String)
          @default = [provided_default]
        end
      end

      # The default message for a Select Question needs to include all of the choices.
      def add_default_to_message(message : String) : String
        choice_string = @choices.map_with_index do |choice, index|
          if default.includes?(choice.strip)
            "[#{index}] #{choice}"
          else
            "(#{index}) #{choice}"
          end
        end.join(" ")

        message + " " + choice_string
      end

      # SelectQuestions need to process user input a bit differently.
      #
      # We support an array of choices with the input, one of which must be selected.
      private def valid_input?(input : String?) : Bool
        if @choices.include?(input)
          true
        else
          false
        end
      end
    end
  end
end
