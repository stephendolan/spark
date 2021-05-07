require "../spec_helper"

describe Spark::Prompt do
  describe "#remote_file" do
    it "successfully fetches and runs valid remote code" do
      WebMock.stub(:get, "https://templates.com").to_return(body: sample_crystal_code)

      File.tempfile do |io|
        Spark::Run.remote_file("https://templates.com", output: io)

        output = io.rewind.gets_to_end
        output.should contain("Hello, this is some Crystal code!")
      end
    end

    it "raises an exception when invalid content is returned from the remote URL" do
      WebMock.stub(:get, "https://google.com").to_return(body: sample_html_code)

      expect_raises(Exception, "Encountered an error when applying a remote file.") do
        Spark::Run.remote_file("https://google.com")
      end
    end

    it "raises an exception when an invalid remote URL is provided" do
      expect_raises(Exception, "Encountered an error when applying a remote file.") do
        Spark::Run.remote_file("nonexistent")
      end
    end
  end

  describe "#local_file" do
    it "successfully runs valid local code" do
      crystal_file = ::File.tempfile
      ::File.write(crystal_file.path, sample_crystal_code)

      File.tempfile do |io|
        Spark::Run.local_file(crystal_file.path, output: io)

        output = io.rewind.gets_to_end
        output.should contain("Hello, this is some Crystal code!")
      end
    end

    it "raises an exception when invalid content is found in the local file" do
      crystal_file = ::File.tempfile
      ::File.write(crystal_file.path, sample_html_code)

      expect_raises(Exception, "Encountered an error when applying a local file.") do
        Spark::Run.local_file(crystal_file.path)
      end
    end

    it "raises an exception when an invalid file path is provided" do
      expect_raises(Exception, "Encountered an error when applying a local file.") do
        Spark::Run.local_file("nonexistent")
      end
    end
  end
end

private def sample_crystal_code : String
  <<-CONTENT
    require "spark"

    prompt = Spark::Prompt.new
    prompt.say "Hello, this is some Crystal code!"
    CONTENT
end

private def sample_html_code : String
  <<-CONTENT
    <HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
    <TITLE>301 Moved</TITLE></HEAD><BODY>
    <H1>301 Moved</H1>
    The document has moved
    <A HREF="https://www.google.com/">here</A>.
    </BODY></HTML>
    CONTENT
end
