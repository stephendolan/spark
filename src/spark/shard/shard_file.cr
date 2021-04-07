module Spark
  module Shard
    class ShardFile
      getter content : String
      getter? has_development_dependencies_section : Bool
      getter? has_production_dependencies_section : Bool

      def initialize(path : String)
        raise_unless_exists(path)

        @content = ::File.read(path)
        @has_development_dependencies_section = check_for_development_dependencies_section
        @has_production_dependencies_section = check_for_dependencies_section
      end

      def contains_shard?(name : String)
        /\b#{name}:\s*\n/.matches?(content)
      end

      # Raises a `Spark::File::MissingShardFileError` if no shard.yml file exists.
      private def raise_unless_exists(path : String)
        return if ::File.exists?(path)

        raise MissingShardFileError.new("Shard file does not exist at '#{path}'.")
      end

      private def check_for_development_dependencies_section
        /\bdevelopment_dependencies:\s*\n/.matches?(content)
      end

      private def check_for_dependencies_section
        /\bdependencies:\s*\n/.matches?(content)
      end
    end
  end
end
