require "http/client"

module Spark
  # Spark::Template facilitates the ability to run Crystal code from a local or remote file.
  #
  # **USE WITH CAUTION**. We do not check file contents before evaluating.
  #
  # Say you have a file with Crystal code you'd like to run that looks like this:
  # ```
  # # /tmp/my_crystal_code.cr
  # prompt = Spark::Prompt.new
  # prompt.say "Hello, from my Crystal file!"
  # ```
  #
  # You could run that code like this:
  # ```
  # Spark::Template.run_local_file("/tmp/my_crystal_code.cr")
  # ```
  module Template
    extend self

    # Execute the Crystal code at a given remote URL.
    #
    # **USE WITH CAUTION**. We do not check file contents before evaluating.
    #
    # Example:
    # ```
    # Spark::Template.run_remote_file("https://railsbytes.com/script/Xg8sya")
    # ```
    def run_remote_file(url : String, output : IO::FileDescriptor = STDOUT)
      Spark.logger.log_action "APPLYING REMOTE TEMPLATE", url, color: :yellow

      response = HTTP::Client.get url

      tempfile = ::File.tempfile
      ::File.write(tempfile.path, response.body)

      apply_file(tempfile.path, output: output)
    rescue error
      Spark.logger.log_action "INVALID REMOTE TEMPLATE", error.message, color: :red
      raise "Encountered an error when applying a remote file."
    end

    # Execute the Crystal code at a given local file path.
    #
    # **USE WITH CAUTION**. We do not check file contents before evaluating.
    #
    # Example:
    # ```
    # Spark::Template.run_local_file("/tmp/my_crystal_file.cr")
    # ```
    def run_local_file(file_path : String, output : IO::FileDescriptor = STDOUT)
      Spark.logger.log_action "APPLYING LOCAL TEMPLATE", file_path, color: :yellow

      apply_file(file_path, output: output)
    rescue error
      Spark.logger.log_action "INVALID LOCAL TEMPLATE", error.message, color: :red
      raise "Encountered an error when applying a local file."
    end

    # Run a given file through `crystal run`
    private def apply_file(file_path : String, output : IO::FileDescriptor = STDOUT)
      unless valid_script_content?(::File.read(file_path))
        raise "Must contain only valid Crystal content"
      end

      add_prefix_file_content(file_path)

      Process.run(command: "crystal", args: ["run", file_path], shell: true, output: output, error: output)
    end

    # Add a require statement for this library to the given file path.
    #
    # This ensures that the Spark code will be accessible in the script.
    private def add_prefix_file_content(file_path : String)
      original_content = ::File.read(file_path)

      new_content = <<-CONTENT
      require "spark"
      CONTENT

      ::File.write(file_path, original_content + "\n" + new_content)
    end

    # Check whether or not the HTTP response from a remote template is valid.
    #
    # This check is kind of basic right now, and basically just makes sure that there aren't top-level HTML tags.
    private def valid_script_content?(http_response_body : String) : Bool
      invalid_patterns = [
        /<html.*>/i,
        /<!DOCTYPE html.*>/i,
      ]

      !http_response_body.matches?(Regex.union(invalid_patterns))
    end
  end
end
