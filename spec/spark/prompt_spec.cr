require "../spec_helper"

describe Spark::Prompt do
  describe "#newline" do
    it "prints a blank line in the output" do
      File.tempfile do |io|
        prompt = Spark::Prompt.new(output: io)
        prompt.say("Testing")
        prompt.newline
        prompt.say("Testing again")
        io.rewind.gets_to_end.should eq("Testing\n\nTesting again\n")
      end
    end
  end

  describe "#log_action" do
    it "does not emit anything when quiet mode is true" do
      File.tempfile do |io|
        Spark.logger = Spark::Prompt.new(output: io)
        Spark.quiet = false

        Spark.quiet do
          Spark.logger.log_action("TESTING", "This is a test")
        end

        Spark.logger.log_action("THIS WILL SHOW")

        io.rewind.gets_to_end.should contain("THIS WILL SHOW")
      end
    end

    it "works with an action and message" do
      File.tempfile do |io|
        Spark.quiet = false
        Spark.logger = Spark::Prompt.new(output: io)
        Spark.logger.log_action("TESTING", "This is a test")
        io.rewind.gets_to_end.should eq("\e[1mTESTING\e[0m -- This is a test\n")
      end
    end

    it "works with only an action" do
      File.tempfile do |io|
        Spark.quiet = false
        Spark.logger = Spark::Prompt.new(output: io)
        Spark.logger.log_action("TESTING")
        io.rewind.gets_to_end.should eq("\e[1mTESTING\e[0m\n")
      end
    end

    it "colorizes output" do
      File.tempfile do |io|
        Spark.quiet = false
        Spark.logger = Spark::Prompt.new(output: io)
        Spark.logger.log_action("TESTING", "This is a test", color: :yellow)
        io.rewind.gets_to_end.should eq("\e[33;1mTESTING\e[0m -- This is a test\n")
      end
    end
  end

  describe "#ask" do
    context "with a validation Regex" do
      context "with retry on" do
        it "successfully collects input until a valid answer is provided" do
          File.tempfile do |output|
            tempfile = File.tempfile do |input|
              input.puts ""
              input.puts "Testing"
              input.puts "Testing"
              input.puts "Testing"
              input.puts "LuckyCasts"
            end

            File.open(tempfile.path) do |input|
              prompt = Spark::Prompt.new(output: output, input: input)

              answer = prompt.ask("What is your name?", color: :yellow, style: :bold) do |question|
                question.validate(/LuckyCasts/, "Invalid, please try again!", retry_on_failure: true)
              end

              output.rewind.gets_to_end.should contain("Invalid, please try again!")

              answer.should eq "LuckyCasts"
            end
          end
        end
      end

      it "correctly fails validations with blank answers" do
        File.tempfile do |output|
          tempfile = File.tempfile do |input|
            input.puts ""
          end

          File.open(tempfile.path) do |input|
            prompt = Spark::Prompt.new(output: output, input: input)

            answer = prompt.ask("What is your name?", color: :yellow, style: :bold) do |question|
              question.validate(/LuckyCasts/)
            end

            output.rewind.gets_to_end.should contain("Your answer does not match '/LuckyCasts/'")

            answer.should be_empty
          end
        end
      end

      it "displays the default message when the answer does not match" do
        File.tempfile do |output|
          tempfile = File.tempfile do |input|
            input.puts "Dingus"
          end

          File.open(tempfile.path) do |input|
            prompt = Spark::Prompt.new(output: output, input: input)

            answer = prompt.ask("What is your name?", color: :yellow, style: :bold) do |question|
              question.validate(/LuckyCasts/)
            end

            output.rewind.gets_to_end.should contain("Your answer does not match '/LuckyCasts/'")

            answer.should be_empty
          end
        end
      end

      it "displays a custom message when the answer does not match" do
        File.tempfile do |output|
          tempfile = File.tempfile do |input|
            input.puts "Dingus"
          end

          File.open(tempfile.path) do |input|
            prompt = Spark::Prompt.new(output: output, input: input)

            answer = prompt.ask("What is your name?", color: :yellow, style: :bold) do |question|
              question.validate(/LuckyCasts/, "You must input 'LuckyCasts' as your answer.")
            end

            output.rewind.gets_to_end.should contain("You must input 'LuckyCasts' as your answer.")

            answer.should be_empty
          end
        end
      end

      it "successfully returns the answer when the answer matches" do
        File.tempfile do |output|
          tempfile = File.tempfile do |input|
            input.puts "LuckyCosts"
          end

          File.open(tempfile.path) do |input|
            prompt = Spark::Prompt.new(output: output, input: input)

            answer = prompt.ask("What is your name?", color: :yellow, style: :bold) do |question|
              question.validate(/LuckyC[a,o]sts/, "You must input 'LuckyCasts' or 'LuckyCosts' as your answer.")
            end

            output.rewind.gets_to_end.should_not contain("You must input 'LuckyCasts' or 'LuckyCosts' as your answer.")

            answer.should eq "LuckyCosts"
          end
        end
      end
    end

    it "does nothing with a zero-length message" do
      File.tempfile do |io|
        prompt = Spark::Prompt.new(output: io)
        prompt.ask("")
        io.rewind.gets_to_end.should eq("")
      end
    end

    it "does nothing with a message of only whitespace" do
      File.tempfile do |io|
        prompt = Spark::Prompt.new(output: io)
        prompt.ask(" " * 20)
        io.rewind.gets_to_end.should eq("")
      end
    end

    it "correctly asks a styled question" do
      File.tempfile do |output|
        tempfile = File.tempfile do |input|
          input.puts "Dingus"
        end

        File.open(tempfile.path) do |input|
          prompt = Spark::Prompt.new(output: output, input: input)

          answer = prompt.ask("What is your name?", color: :yellow, style: :bold)
          output.rewind.gets_to_end.should eq("\e[33;1mWhat is your name? \e[0m")
          answer.should eq "Dingus"
        end
      end
    end

    it "strips whitespace from answers" do
      File.tempfile do |output|
        tempfile = File.tempfile do |input|
          input.puts "  Dingus   "
        end

        File.open(tempfile.path) do |input|
          prompt = Spark::Prompt.new(output: output, input: input)

          answer = prompt.ask("What is your name?")
          output.rewind.gets_to_end.should contain("What is your name?")
          answer.should eq "Dingus"
        end
      end
    end

    it "returns an empty string for an empty answer" do
      File.tempfile do |output|
        tempfile = File.tempfile do |input|
          input.puts ""
        end

        File.open(tempfile.path) do |input|
          prompt = Spark::Prompt.new(output: output, input: input)

          answer = prompt.ask("What is your name?")
          output.rewind.gets_to_end.should eq("What is your name? ")
          answer.should eq ""
        end
      end
    end

    it "correctly uses the default answer" do
      File.tempfile do |output|
        tempfile = File.tempfile do |input|
          input.puts ""
        end

        File.open(tempfile.path) do |input|
          prompt = Spark::Prompt.new(output: output, input: input)

          answer = prompt.ask("What is your name?", default: "LuckyCasts")
          output.rewind.gets_to_end.should eq("What is your name? [LuckyCasts] ")
          answer.should eq "LuckyCasts"
        end
      end
    end
  end

  describe "#yes?" do
    truthy_answers = [nil, "Y", "y", "YES", "Yes", "yes"]
    falsey_answers = ["N", "n", "NO", "No", "no"]

    truthy_answers.each do |answer|
      it "returns true for a '#{answer}' answer" do
        File.tempfile do |output|
          tempfile = File.tempfile do |input|
            input.puts "#{answer}"
          end

          File.open(tempfile.path) do |input|
            prompt = Spark::Prompt.new(output: output, input: input)

            answer = prompt.yes?("Are you sure?")
            output.rewind.gets_to_end.should eq("Are you sure? [Y/n] ")
            answer.should eq true
          end
        end
      end
    end

    falsey_answers.each do |answer|
      it "returns false for a '#{answer}' answer" do
        File.tempfile do |output|
          tempfile = File.tempfile do |input|
            input.puts "#{answer}"
          end

          File.open(tempfile.path) do |input|
            prompt = Spark::Prompt.new(output: output, input: input)

            answer = prompt.yes?("Are you sure?")
            output.rewind.gets_to_end.should eq("Are you sure? [Y/n] ")
            answer.should eq false
          end
        end
      end
    end

    it "does nothing with a zero-length message" do
      File.tempfile do |io|
        prompt = Spark::Prompt.new(output: io)
        prompt.yes?("")
        io.rewind.gets_to_end.should eq("")
      end
    end

    it "does nothing with a message of only whitespace" do
      File.tempfile do |io|
        prompt = Spark::Prompt.new(output: io)
        prompt.yes?(" " * 20)
        io.rewind.gets_to_end.should eq("")
      end
    end

    it "correctly asks a styled question" do
      File.tempfile do |output|
        tempfile = File.tempfile do |input|
          input.puts "Y"
        end

        File.open(tempfile.path) do |input|
          prompt = Spark::Prompt.new(output: output, input: input)

          answer = prompt.yes?("Are you sure?", color: :yellow, style: :bold)
          output.rewind.gets_to_end.should eq("\e[33;1mAre you sure? [Y/n] \e[0m")
          answer.should eq true
        end
      end
    end
  end

  describe "#no?" do
    truthy_answers = ["Y", "y", "YES", "Yes", "yes"]
    falsey_answers = [nil, "N", "n", "NO", "No", "no"]

    truthy_answers.each do |answer|
      it "returns false for a '#{answer}' answer" do
        File.tempfile do |output|
          tempfile = File.tempfile do |input|
            input.puts "#{answer}"
          end

          File.open(tempfile.path) do |input|
            prompt = Spark::Prompt.new(output: output, input: input)

            answer = prompt.no?("Are you sure?")
            output.rewind.gets_to_end.should eq("Are you sure? [y/N] ")
            answer.should eq false
          end
        end
      end
    end

    falsey_answers.each do |answer|
      it "returns true for a '#{answer}' answer" do
        File.tempfile do |output|
          tempfile = File.tempfile do |input|
            input.puts "#{answer}"
          end

          File.open(tempfile.path) do |input|
            prompt = Spark::Prompt.new(output: output, input: input)

            answer = prompt.no?("Are you sure?")
            output.rewind.gets_to_end.should eq("Are you sure? [y/N] ")
            answer.should eq true
          end
        end
      end
    end

    it "does nothing with a zero-length message" do
      File.tempfile do |io|
        prompt = Spark::Prompt.new(output: io)
        prompt.no?("")
        io.rewind.gets_to_end.should eq("")
      end
    end

    it "does nothing with a message of only whitespace" do
      File.tempfile do |io|
        prompt = Spark::Prompt.new(output: io)
        prompt.no?(" " * 20)
        io.rewind.gets_to_end.should eq("")
      end
    end

    it "correctly asks a styled question" do
      File.tempfile do |output|
        tempfile = File.tempfile do |input|
          input.puts "N"
        end

        File.open(tempfile.path) do |input|
          prompt = Spark::Prompt.new(output: output, input: input)

          answer = prompt.no?("Are you sure?", color: :yellow, style: :bold)
          output.rewind.gets_to_end.should eq("\e[33;1mAre you sure? [y/N] \e[0m")
          answer.should eq true
        end
      end
    end
  end

  describe "#decorate" do
    context "with no options" do
      it "decorates with the default color" do
        prompt = Spark::Prompt.new
        output = prompt.decorate("Hello, there!")
        output.should eq("Hello, there!".colorize(:default))
      end
    end

    context "with colorization" do
      it "colorizes the text" do
        prompt = Spark::Prompt.new
        output = prompt.decorate("Hello, there!", color: :green)
        output.should eq("Hello, there!".colorize(:green))
      end

      it "raises an error with an invalid color" do
        prompt = Spark::Prompt.new
        expect_raises(ArgumentError) do
          prompt.decorate("Hello, there!", color: :perrywinkle)
        end
      end
    end

    context "with style" do
      it "stylizes the text" do
        prompt = Spark::Prompt.new
        output = prompt.decorate("Hello, there!", style: :bold)
        output.should eq("Hello, there!".colorize.mode(:bold))
      end

      it "raises an error with an invalid style" do
        prompt = Spark::Prompt.new
        expect_raises(ArgumentError) do
          prompt.decorate("Hello, there!", style: :wiggley)
        end
      end
    end

    context "with color and style" do
      it "colorizes and stylizes the text" do
        prompt = Spark::Prompt.new
        output = prompt.decorate("Hello, there!", color: :green, style: :bold)
        output.should eq("Hello, there!".colorize(:green).mode(:bold))
      end
    end
  end

  describe "#say" do
    it "does nothing with a zero-length message" do
      File.tempfile do |io|
        prompt = Spark::Prompt.new(output: io)
        prompt.say("")
        io.rewind.gets_to_end.should eq("")
      end
    end

    it "does nothing with a message of only whitespace" do
      File.tempfile do |io|
        prompt = Spark::Prompt.new(output: io)
        prompt.say(" " * 20)
        io.rewind.gets_to_end.should eq("")
      end
    end

    it "displays a plain message" do
      File.tempfile do |io|
        prompt = Spark::Prompt.new(output: io)
        prompt.say("Hello, there!")
        io.rewind.gets_to_end.should eq("Hello, there!\n")
      end
    end

    it "displays a message without newlines" do
      File.tempfile do |io|
        prompt = Spark::Prompt.new(output: io)
        prompt.say("Hello, there!", newline: false)
        io.rewind.gets_to_end.should eq("Hello, there!")
      end
    end

    it "displays a stylized message" do
      File.tempfile do |io|
        prompt = Spark::Prompt.new(output: io)
        prompt.say("Hello, there!", color: :green, style: :bold)
        io.rewind.gets_to_end.should eq("\e[32;1mHello, there!\e[0m\n")
      end
    end
  end
end
