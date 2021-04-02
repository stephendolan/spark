require "./spec_helper"

describe Spark::Prompt do
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
