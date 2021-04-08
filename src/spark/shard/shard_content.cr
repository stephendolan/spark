module Spark
  module Shard
    class ShardContent
      getter name
      getter github, git
      getter version, branch

      def initialize(@name : String, @github : String? = nil, @git : String? = nil, @version : String? = nil, @branch : String? = nil)
      end

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

      # Every shard should be nested under a header section, so we always indent with two spaces.
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
