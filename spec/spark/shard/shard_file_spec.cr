require "../../spec_helper"

describe Spark::Shard::ShardFile do
  it "throws an error if the provided shard file does not exist" do
    expect_raises(MissingShardFileError) do
      Spark::Shard::ShardFile.new("nonexistent")
    end
  end

  it "correctly detects solo development dependencies sections" do
    file = File.tempfile do |io|
      content = <<-CONTENT
        name: spark
        version: x.x.x
    
        authors:
          - Test Author <testauthor@example.com>
    
        crystal: x.x.x
    
        license: MIT
    
        development_dependencies:
          spark:
            github: stephendolan/spark
            branch: master
        CONTENT

      io.puts content
    end

    shard_file = Spark::Shard::ShardFile.new(file.path)
    shard_file.has_development_dependencies_section?.should eq true
    shard_file.has_production_dependencies_section?.should eq false
  end

  it "correctly detects solo dependencies sections" do
    file = File.tempfile do |io|
      content = <<-CONTENT
        name: spark
        version: x.x.x
    
        authors:
          - Test Author <testauthor@example.com>
    
        crystal: x.x.x
    
        license: MIT
    
        dependencies:
          spark:
            github: stephendolan/spark
            branch: master
        CONTENT

      io.puts content
    end

    shard_file = Spark::Shard::ShardFile.new(file.path)
    shard_file.has_development_dependencies_section?.should eq false
    shard_file.has_production_dependencies_section?.should eq true
  end

  it "correctly detects both types of dependencies sections" do
    file = File.tempfile do |io|
      content = <<-CONTENT
        name: spark
        version: x.x.x
    
        authors:
          - Test Author <testauthor@example.com>
    
        crystal: x.x.x
    
        license: MIT
    
        dependencies:
          spark:
            github: stephendolan/spark
            branch: master

        development_dependencies:
          lucky_flow:
            github: luckyframework/lucky_flow
            branch: master
        CONTENT

      io.puts content
    end

    shard_file = Spark::Shard::ShardFile.new(file.path)
    shard_file.has_development_dependencies_section?.should eq true
    shard_file.has_production_dependencies_section?.should eq true
  end

  describe "#contains_shard?" do
    it "correctly detects an existing shard" do
      file = File.tempfile do |io|
        content = <<-CONTENT
          name: spark
          version: x.x.x
      
          authors:
            - Test Author <testauthor@example.com>
      
          crystal: x.x.x
      
          license: MIT
      
          dependencies:
            spark:
              github: stephendolan/spark
              branch: master
          CONTENT

        io.puts content
      end

      shard_file = Spark::Shard::ShardFile.new(file.path)
      shard_file.contains_shard?("spark").should eq true
    end

    it "does not throw false positives" do
      file = File.tempfile do |io|
        content = <<-CONTENT
          name: spark
          version: x.x.x
      
          authors:
            - Test Author <testauthor@example.com>
      
          crystal: x.x.x
      
          license: MIT
      
          dependencies:
            not_spark:
              github: stephendolan/spark
              branch: master
          CONTENT

        io.puts content
      end

      shard_file = Spark::Shard::ShardFile.new(file.path)
      shard_file.contains_shard?("spark").should eq false
    end
  end
end
