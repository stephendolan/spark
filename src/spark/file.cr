require "./file/*"

require "file_utils"

module Spark
  # Spark::File allows you to interact with the user's filesystem.
  module File
    extend self

    BEGINNING_OF_FILE_REGEX = /\A/
    END_OF_FILE_REGEX       = /\z/

    # Replace a specific pattern with some replacement text throughout a given file.
    #
    # Example:
    # ```
    # Spark::File.replace_in_file("shard.yml", pattern: "MIT", replacement: "Apache")
    # ```
    def replace_in_file(relative_path : String, pattern : Regex | String, replacement : String)
      raise_unless_exists(relative_path)

      Spark.logger.log_action "REPLACING CONTENT", "#{relative_path} - '#{pattern.inspect}' for '#{replacement}'", color: :yellow

      pattern = process_pattern(pattern)
      existing_file_content = ::File.read(relative_path)
      new_file_content = existing_file_content.gsub(pattern, replacement)

      ::File.write(relative_path, new_file_content)
    end

    # Prepend any number of strings to the beginning of a file.
    #
    # Example:
    # ```
    # Spark::File.prepend_to_file("README.md", "# Welcome!", "You're at the top of the README.")
    # ```
    def prepend_to_file(relative_path : String, *content)
      inject_into_file(relative_path, *content, before: BEGINNING_OF_FILE_REGEX)
    end

    # Prepend the provided block content to the beginning of a file.
    #
    # Example:
    # ```
    # Spark::File.prepend_to_file("README.md") do
    #   <<-CONTENT
    #   # Welcome
    #
    #   You're at the top of the README.
    #   CONTENT
    # end
    # ```
    def prepend_to_file(relative_path : String, & : -> String)
      inject_into_file(relative_path, yield, before: BEGINNING_OF_FILE_REGEX)
    end

    # Append any number of strings to the end of a file.
    #
    # Example:
    # ```
    # Spark::File.append_to_file("README.md", "# Goodbye!", "You're at the bottom of the README.")
    # ```
    def append_to_file(relative_path : String, *content)
      inject_into_file(relative_path, *content, after: END_OF_FILE_REGEX)
    end

    # Append the provided block content to the end of a file.
    #
    # Example:
    # ```
    # Spark::File.append_to_file("README.md") do
    #   <<-CONTENT
    #   # Goodbye
    #
    #   You're at the bottom of the README.
    #   CONTENT
    # end
    # ```
    def append_to_file(relative_path : String, & : -> String)
      inject_into_file(relative_path, yield, after: END_OF_FILE_REGEX)
    end

    # Create a new file with the provided content.
    #
    # Example:
    # ```
    # Spark::File.create_file("README.md", "# Welcome\n\n", "This is my new file.")
    # ```
    def create_file(relative_path : String, *content) : String
      file_content = content.join

      CreateFile.new(relative_path, file_content).call
    end

    # Create a new file with the provided block content.
    #
    # Example:
    # ```
    # Spark::File.create_file("README.md") do
    #   <<-CONTENT
    #   # Welcome
    #
    #   This is my new file.
    #   CONTENT
    # end
    # ```
    def create_file(relative_path : String, & : -> String) : String
      CreateFile.new(relative_path, yield).call
    end

    # Remove a file.
    #
    # Removing a single file:
    # ```
    # Spark::File.remove_file("README.md")
    # ```
    #
    # Removing a directory:
    # ```
    # Spark::File.remove_file("src/")
    # ```
    def remove_file(relative_path : String)
      Spark.logger.log_action "REMOVING", relative_path, color: :red

      return unless ::File.exists?(relative_path)

      ::FileUtils.rm_r(relative_path)
    end

    # Copy a file from a provided source path to a provided destination.
    #
    # Example:
    # ```
    # Spark::File.copy_file("README.md", "IDENTICAL_README.md")
    # ```
    def copy_file(source_path : String, destination_path : String) : String
      raise_unless_exists(source_path)

      Spark.logger.log_action "COPYING", "'#{source_path}' to '#{destination_path}'", color: :green

      Spark.quiet do
        create_file(destination_path, ::File.read(source_path))
      end
    end

    # Move a file from the provided source path to the provided destination.
    #
    # Note that the source file will no longer exist after this action.
    # If you wish to preserve the source file, use `Spark::File.copy_file`.
    #
    # Example:
    # ```
    # Spark::File.move_file("README.md", "NEW_README.md")
    # ```
    def move_file(source_path : String, destination_path : String) : String
      raise_unless_exists(source_path)

      Spark.logger.log_action "MOVING", "'#{source_path}' to '#{destination_path}'", color: :yellow

      Spark.quiet do
        new_path = copy_file(source_path, destination_path)
        remove_file(source_path)

        new_path
      end
    end

    # Inject any number of strings *after* the provided pattern.
    #
    # Example:
    # ```
    # Spark::File.inject_into_file("README.md", "# New Section", after: "# Last Section\n")
    # ```
    def inject_into_file(relative_path : String, *content, after pattern : Regex | String)
      replacement = "\\0" + content.join

      replace_in_file(relative_path, pattern, replacement)
    end

    # Inject the provided block content *after* the provided pattern.
    #
    # Example:
    # ```
    # Spark::File.inject_into_file("README.md", after: "# Last Section\n") do
    #   <<-CONTENT
    #   This is some new file content.
    #   It's going to be great!\n
    #   CONTENT
    # end
    # ```
    def inject_into_file(relative_path : String, *, after pattern : Regex | String, & : -> String)
      replacement = "\\0#{yield}"

      replace_in_file(relative_path, pattern, replacement)
    end

    # Inject any number of strings *before* the provided pattern.
    #
    # Example:
    # ```
    # Spark::File.inject_into_file("README.md", "# New Section", before: "# First Section\n")
    # ```
    def inject_into_file(relative_path : String, *content, before pattern : Regex | String)
      replacement = content.join + "\\0"

      replace_in_file(relative_path, pattern, replacement)
    end

    # Inject the provided block content *before* the provided pattern.
    #
    # Example:
    # ```
    # Spark::File.inject_into_file("README.md", before: "# First Section\n") do
    #   <<-CONTENT
    #   This is some new file content.
    #   It's going to be great!\n
    #   CONTENT
    # end
    # ```
    def inject_into_file(relative_path : String, *, before pattern : Regex | String, & : -> String)
      replacement = "#{yield}\\0"

      replace_in_file(relative_path, pattern, replacement)
    end

    # Raises a `Spark::File::InvalidPathError` if the provided path does not exist.
    private def raise_unless_exists(path : String)
      return if ::File.exists?(path)

      raise InvalidPathError.new("File path '#{path}' does not exist.")
    end

    # Given a `String` or `Regex`, ensure that a `Regex` is returned.
    private def process_pattern(pattern : Regex | String) : Regex
      case pattern
      when Regex
        pattern
      else
        Regex.new(pattern)
      end
    end
  end
end
