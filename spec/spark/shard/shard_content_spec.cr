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
      content = Spark::Shard::ShardContent.new(name: "test", branch: "master")
      content.version_or_branch.should eq "branch: master\n"
    end
  end

  describe "#to_s" do
    pending "works"
  end
end
