require "./spark/*"

# Spark is a CLI Utility library that makes working with users on the
# command line simpler than ever.
module Spark
  extend self

  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}

  # Whether or not to suppress optional terminal output to users.
  def quiet?
    if (value = @@quiet).nil?
      @@quiet = false
    else
      value
    end
  end

  # Force a block of code to run in quiet mode.
  #
  # Example:
  # ```
  # Spark.quiet do
  #   Spark::Prompt.new.log_status("TESTING")
  # end
  # # => ""
  # ```
  def quiet(&)
    old_quiet_value = quiet?
    @@quiet = true

    output = yield

    @@quiet = old_quiet_value

    output
  end

  # Control whether or not optional terminal output is displayed to users.
  #
  # Example:
  # ```
  # Spark.logger.log_status("Testing") # => This will print something to the user
  # Spark.quiet = true
  # Spark.logger.log_status("Testing") # => Nothing will print to the user
  # ```
  def quiet=(@@quiet)
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
