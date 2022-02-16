require "./question"

module Spark
  class Prompt
    class ConfirmationQuestion < Question
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

      private def add_default_to_message(message : String) : String
        case default
        when Bool
          if default == true
            message + " [Y/n]"
          else
            message + " [y/N]"
          end
        else
          message
        end
      end
    end
  end
end
