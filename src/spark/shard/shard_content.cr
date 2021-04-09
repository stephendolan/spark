module Spark
  module Shard
    class ShardContent
      # The name of the shard
      getter name

      # The GitHub spath of the shard.
      #
      # Example:
      # ```
      # stephendolan/spark
      # ```
      getter github

      # The git URL of the shard.
      #
      # Example:
      # ```
      # https://mycustomserver.com/stephendolan/spark
      # ```
      getter git

      # The version of the shard.
      # Either `#version` or `#branch` may be optionally provided, but not both.
      #
      # Example:
      # ```
      # ~> 1.0.3
      # ```
      getter version

      # The branch of the shard to use.
      # Either `#version` or `#branch` may be optionally provided, but not both.
      #
      # Example:
      # ```
      # main
      # ```
      getter branch

      # Given some basic shard information, provides an object that can be written to `shard.yml` with `#to_s`.
      def initialize(@name : String, @github : String? = nil, @git : String? = nil, @version : String? = nil, @branch : String? = nil)
      end

      # Intelligently determine whether to use the GitHub or git source for a shard.
      #
      # Outputs a `shard.yml`-friendly version of the source.
      #
      # Example:
      # ```
      # Spark::Shard::ShardContent.new(name: "test", github: "stephendolan/spark").source                         # => "github: stephendolan/spark"
      # Spark::Shard::ShardContent.new(name: "test", git: "https://custom-git.com/stephendolan/spark.git").source # => "git: https://custom-git.com/stephendolan/spark.git"
      # ```
      def source
        if github.nil? && git.nil?
          raise ArgumentError.new("Must provide either `git` or `github` for shard content.")
        end

        if github && git
          raise ArgumentError.new("Cannot provide both `git` and `github` for shard content.")
        end

        if github
          "github: #{github}"
        else
          "git: #{git}"
        end
      end

      # Intelligently determine whether to use the branch or a version string for the shard.
      #
      # Outputs a `shard.yml`-friendly variant of the version or branch, which is always suffixed
      # with a newline since it is the last line in a shard definition. This allows for a simpler `#to_s` implementation.
      #
      # Example:
      # ```
      # Spark::Shard::ShardContent.new(name: "test", github: "stephendolan/spark", version: "~> 1.0.3").version_or_branch # => "version: ~> 1.0.3\n"
      # Spark::Shard::ShardContent.new(name: "test", github: "stephendolan/spark", branch: "master").version_or_branch    # => "branch: main\n"
      # ```
      def version_or_branch
        if version && branch
          raise ArgumentError.new("Cannot provide both `version` and `branch` for shard content.")
        end

        if version
          "version: #{version}\n"
        elsif branch
          "branch: #{branch}\n"
        else
          ""
        end
      end

      # Outputs a `shard.yml`-friendly representation of the given shard content.
      #
      # Every shard should be nested under a header section, so we always indent with two spaces.
      #
      # Example:
      # ```
      # shard_content = Spark::Shard::ShardContent.new(name: "spark", github: "stephendolan/spark", version: "~> 1.0.3")
      # shard_content.to_s # => <<-CONTENT
      #   spark:
      #     github: stephendolan/spark
      #     version: ~> 1.0.3
      # CONTENT
      # ```
      def to_s
        output = <<-CONTENT
          #{name}:
            #{source}
            #{version_or_branch}
        CONTENT

        # Remove any trailing whitespace
        output.rstrip(" ")
      end
    end
  end
end
