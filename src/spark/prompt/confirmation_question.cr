require "./question"

module Spark
  class Prompt
    class ConfirmationQuestion < Question
      # ConfirmationQuestions need to process user input a bit differently.
      #
      # We support variations of "yes" and "no" as answers, as well as empty answers.
      private def process_input(input : String?)
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
        end
      end
    end
  end
end
