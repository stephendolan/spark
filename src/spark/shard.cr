require "./shard/*"

module Spark
  module Shard
    extend self

    # Which path to search to find the Crystal shard definition.
    def shard_file_path
      if (value = @@shard_file_path).nil?
        @@shard_file_path = "shard.yml"
      else
        value
      end
    end

    # Control which path to search to find the Crystal shard definition.
    def shard_file_path=(@@shard_file_path)
    end

    def add_shard(name : String, *, development_only : Bool = false, **options)
      shard_file = ShardFile.new(shard_file_path)

      Spark.logger.log_action("ADD SHARD", name, color: :green)

      return if shard_file.contains_shard?(name)

      shard_content = ShardContent.new(name, **options).to_s

      if development_only
        add_development_shard(shard_file, shard_content)
      else
        add_production_shard(shard_file, shard_content)
      end
    end

    private def add_production_shard(shard_file : Spark::Shard::ShardFile, content : String)
      header = "dependencies:"
      content_with_header = "#{header}\n#{content}"

      case shard_file
      when .has_production_dependencies_section?
        Spark::File.inject_into_file(shard_file_path, content, after: /\b#{header}\s*\n/)
      when .has_development_dependencies_section?
        Spark::File.inject_into_file(shard_file_path, "#{content_with_header}\n", before: /\bdevelopment_#{header}\s*\n/)
      else
        Spark::File.append_to_file(shard_file_path, "\n#{content_with_header}")
      end
    end

    private def add_development_shard(shard_file : Spark::Shard::ShardFile, content : String)
      header = "development_dependencies:"
      content_with_header = "#{header}\n#{content}"

      case shard_file
      when .has_development_dependencies_section?
        Spark::File.inject_into_file(shard_file_path, content, after: /\b#{header}\s*\n/)
      else
        Spark::File.append_to_file(shard_file_path, "\n#{content_with_header}")
      end
    end
  end
end
