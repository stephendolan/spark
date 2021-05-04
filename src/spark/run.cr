require "http/client"

module Spark
  module Run
    extend self

    # Execute the Crystal code at a given remote URL.
    #
    # USE WITH EXTREME CAUTION. WE DO NOT CHECK FILE CONTENTS BEFORE RUNNING.
    def remote_file(url : String)
      Spark.logger.log_action "APPLYING REMOTE TEMPLATE", url, color: :yellow
      response = HTTP::Client.get url
      tempfile = ::File.tempfile
      ::File.write(tempfile.path, response.body)
      apply_file(tempfile.path)
    end

    # Execute the Crystal code at a given remote URL.
    #
    # USE WITH EXTREME CAUTION. WE DO NOT CHECK FILE CONTENTS BEFORE RUNNING.
    def local_file(file_path : String)
      Spark.logger.log_action "APPLYING LOCAL TEMPLATE", file_path, color: :yellow

      apply_file(file_path)
    end

    private def apply_file(file_path : String)
      add_prefix_file_content(file_path)
      Process.run(command: "crystal", args: ["run", file_path], shell: true, output: STDOUT, error: STDERR)
    end

    private def add_prefix_file_content(file_path : String)
      original_content = ::File.read(file_path)

      new_content = <<-CONTENT
      require "spark"
      CONTENT

      ::File.write(file_path, original_content + "\n" + new_content)
    end
  end
end
