module Spark
  module Shard
    class ShardFile
      # The content of the shard file in its entirety.
      getter content : String

      # Whether or not the `development_dependencies:` header exists in the shard file.
      getter? has_development_dependencies_section : Bool

      # Whether or not the `dependencies:` header exists in the shard file.
      getter? has_production_dependencies_section : Bool

      # Creates a new `ShardFile` that parses the given path for `shard.yml` content.
      def initialize(path : String)
        raise_unless_exists(path)

        @content = ::File.read(path)
        @has_development_dependencies_section = check_for_development_dependencies_section
        @has_production_dependencies_section = check_for_dependencies_section
      end

      # Determine whether or not the `ShardFile` already has an entry for the given shard.
      #
      # Example:
      # ```yaml
      #   name: test_shard_yml
      #
      #   version: x.x.x
      #
      #   dependencies:
      #     spark:
      #       github: stephendolan/spark
      # ```
      #
      # ```
      # Spark::Shard::ShardFile.new("shard.yml").contains_shard?("spark") # => true
      # Spark::Shard::ShardFile.new("shard.yml").contains_shard?("lucky") # => false
      # ```
      def contains_shard?(name : String)
        /\b#{name}:\s*\n/.matches?(content)
      end

      # Raises a `Spark::File::MissingShardFileError` if no shard.yml file exists.
      private def raise_unless_exists(path : String)
        return if ::File.exists?(path)

        raise MissingShardFileError.new("Shard file does not exist at '#{path}'.")
      end

      # Check the `ShardFile` for a `development_dependencies` header.
      private def check_for_development_dependencies_section
        /\bdevelopment_dependencies:\s*\n/.matches?(content)
      end

      # Check the `ShardFile` for a `dependencies` header.
      private def check_for_dependencies_section
        /\bdependencies:\s*\n/.matches?(content)
      end
    end
  end
end
