require "./question"

module Spark
  class Prompt
    class ConfirmationQuestion < Question(Bool, Bool)
      # ConfirmationQuestions need to process user input a bit differently.
      #
      # We support variations of "yes" and "no" as answers, as well as empty answers.
      private def process_input(input : String?) : Bool
        case default
        when Bool && false
          if input =~ /y(es)?/i
            false
          else
            true
          end
        when Bool && true
          if input =~ /n(o)?/i
            false
          else
            true
          end
        else
          raise ArgumentError.new("The `default` supplied to a ConfirmationQuestion must be `true` or `false`.")
        end
      end
    end
  end
end
