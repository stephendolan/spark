module Spark
  # Spark::File allows you to interact with the user's filesystem.
  module File
    extend self

    # Thrown when a provided file path does not exist.
    class InvalidPathError < ArgumentError; end

    # Raises a `Spark::File::InvalidPathError` if the provided path does not exist.
    def raise_unless_exists(path : String)
      return if ::File.exists?(path)

      raise InvalidPathError.new("File path '#{path}' does not exist.")
    end

    # Replace a specific pattern with some replacement text throughout a given file.
    #
    # Example:
    # ```
    # Spark::File.replace_in_file("shard.yml", pattern: "MIT", replacement: "Apache")
    # ```
    def replace_in_file(relative_path : String, pattern : Regex | String, replacement : String)
      pattern = process_pattern(pattern)
      existing_file_content = ::File.read(relative_path)
      new_file_content = existing_file_content.gsub(pattern, replacement)
      ::File.write(relative_path, new_file_content)
    end

    # Inject any number of strings *after* the provided pattern.
    #
    # Example:
    # ```
    # Spark::File.inject_into_file("README.md", "# New Section", after: "# Last Section\n")
    # ```
    def inject_into_file(relative_path : String, *args, after pattern : Regex | String)
      replacement = "\\0" + args.join

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
    def inject_into_file(relative_path : String, after pattern : Regex | String, &block : -> String)
      replacement = "\\0" + block.call

      replace_in_file(relative_path, pattern, replacement)
    end

    # Inject any number of strings *before* the provided pattern.
    #
    # Example:
    # ```
    # Spark::File.inject_into_file("README.md", "# New Section", before: "# First Section\n")
    # ```
    def inject_into_file(relative_path : String, *args, before pattern : Regex | String)
      replacement = args.join + "\\0"

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
    def inject_into_file(relative_path : String, before pattern : Regex | String, &block : -> String)
      replacement = block.call + "\\0"

      replace_in_file(relative_path, pattern, replacement)
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
