require "../../spec_helper"

describe Spark::Shard::ShardContent do
  describe "#source" do
    it "raises an error if both `git` and `github` sources are provided" do
      expect_raises(ArgumentError) do
        Spark::Shard::ShardContent.new(name: "test", git: "test-git", github: "test-github").source
      end
    end

    it "raises an error if neither `git` or `github` sources are provided" do
      expect_raises(ArgumentError) do
        Spark::Shard::ShardContent.new(name: "test").source
      end
    end

    it "outputs a valid source when git is provided" do
      content = Spark::Shard::ShardContent.new(name: "test", git: "https://git.com/my-custom-repo")
      content.source.should eq "git: https://git.com/my-custom-repo"
    end

    it "outputs a valid source when a github repository is provided" do
      content = Spark::Shard::ShardContent.new(name: "test", github: "stephendolan/spark")
      content.source.should eq "github: stephendolan/spark"
    end
  end

  describe "#version_or_branch" do
    it "raises an error if both `git` and `github` sources are provided" do
      expect_raises(ArgumentError) do
        Spark::Shard::ShardContent.new(name: "test", version: "1.0.0", branch: "test").version_or_branch
      end
    end

    it "outputs a valid version string when a version is provided" do
      content = Spark::Shard::ShardContent.new(name: "test", version: "1.0.0")
      content.version_or_branch.should eq "version: 1.0.0\n"
    end

    it "outputs a valid branch string when a branch is provided" do
      content = Spark::Shard::ShardContent.new(name: "test", branch: "main")
      content.version_or_branch.should eq "branch: main\n"
    end
  end

  describe "#to_s" do
    it "handles just a source" do
      content = Spark::Shard::ShardContent.new(name: "test", github: "testing/test").to_s
      content.should eq <<-CONTENT
        test:
          github: testing/test\n
      CONTENT
    end

    it "handles a source and version" do
      content = Spark::Shard::ShardContent.new(name: "test", github: "testing/test", version: "~> 1.0.3").to_s
      content.should eq <<-CONTENT
        test:
          github: testing/test
          version: ~> 1.0.3\n
      CONTENT
    end
  end
end
