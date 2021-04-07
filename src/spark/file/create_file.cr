module Spark
  module File
    # CreateFile acts as a convenient wrapper to perform file creation.
    class CreateFile
      getter relative_path : String
      getter content : String

      # Set up a new CreateFile object for creation.
      def initialize(@relative_path : String, @content : String)
      end

      # Create the initialized `CreateFile` object.
      def call
        Spark.logger.log_action "CREATING", "#{relative_path}", color: :green

        Dir.mkdir_p(::File.dirname(relative_path))
        ::File.write(relative_path, content)

        relative_path
      end
    end
  end
end
