module Spark
  module File
    # CreateFile acts as a convenient wrapper to perform file creation.
    class CreateFile
      getter base
      getter relative_path
      getter content

      # Set up a new CreateFile object for creation.
      def initialize(@relative_path : String, @content : String)
      end

      # Create the initialized `CreateFile` object.
      def call
        Dir.mkdir_p(::File.dirname(relative_path))
        ::File.write(relative_path, content)

        relative_path
      end
    end
  end
end
