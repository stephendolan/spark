require "./question"

module Spark
  class Prompt
    class ConfirmationQuestion < Question
      private def process_input(input : String?)
        case input
        when /y(es)?/i
          if default.is_a?(Bool) && default == false
            false
          else
            true
          end
        when /n(o)?/i
          if default.is_a?(Bool) && default == true
            false
          else
            true
          end
        else
          if default.is_a?(Bool) && default == false
            true
          else
            default
          end
        end
      end
    end
  end
end
