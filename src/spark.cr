require "./spark/*"

# Spark is a CLI Utility library that makes working with users on the
# command line simpler than ever.
module Spark
  extend self

  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}

  # Determines how much to indent all Spark terminal output by.
  @@indent_level : Int32 = 0

  def indent_level
    @@indent_level
  end

  # Increase the indentation level for `Spark` output by one level.
  def indent
    @@indent_level += 1
  end

  # Decrease the indentation level for `Spark` output by one level.
  #
  # Cannot be decreased below zero.
  def outdent
    @@indent_level -= 1

    if @@indent_level < 0
      @@indent_level = 0
    end
  end

  # Reset the Spark indentation level back to 0.
  def reset_indentation
    @@indent_level = 0
  end

  # Whether or not to suppress optional terminal output to users.
  def quiet?
    if (value = @@quiet).nil?
      @@quiet = false
    else
      value
    end
  end

  # Control whether or not optional terminal output is displayed to users.
  #
  # Example:
  # ```
  # Spark.logger.log_action("Testing") # => This will print something to the user
  # Spark.quiet = true
  # Spark.logger.log_action("Testing") # => Nothing will print to the user
  # ```
  def quiet=(@@quiet)
  end

  # Force a block of code to run in a temporary quiet mode setting.
  #
  # Example temporarily enabling:
  # ```
  # Spark.quiet do
  #   Spark::Prompt.new.log_action("TESTING")
  # end
  # # => ""
  # ```
  #
  # Example temporarily disabling:
  # ```
  # Spark.quiet(false) do
  #   Spark::Prompt.new.log_action("TESTING")
  # end
  # # => ""
  # ```
  def quiet(active : Bool = true, &)
    old_quiet_value = quiet?
    @@quiet = active

    output = yield

    @@quiet = old_quiet_value

    output
  end

  # Which object to use for logging optional output to users.
  def logger : Spark::Prompt
    if (value = @@logger).nil?
      @@logger = Spark::Prompt.new
    else
      value
    end
  end

  # Control which object is used to log optional output to users.
  #
  # Example:
  # ```
  # Spark.logger = Spark::Prompt.new(input: File.tempfile.open, output: File.tempfile.open)
  # ```
  def logger=(@@logger : Spark::Prompt)
  end
end
