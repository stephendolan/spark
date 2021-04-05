require "../spec_helper"

describe Spark::Prompt do
  describe ".create_file" do
    it "writes multiple arguments to the file" do
      file_path = Spark::File.create_file(File.tempfile.path, "Line one\n", "Line two")

      File.read(file_path).should eq "Line one\nLine two"
    end

    it "writes block content to the file" do
      file_path = Spark::File.create_file(File.tempfile.path) do
        <<-CONTENT
        Line one
        Line two
        CONTENT
      end

      File.read(file_path).should eq "Line one\nLine two"
    end
  end

  describe ".copy_file" do
    it "copies a simple file identically" do
      original_file = File.tempfile do |io|
        io.puts "Line one\nLine two"
      end

      new_file = File.tempfile

      Spark::File.copy_file(original_file.path, new_file.path)
      File.read(new_file.path).should eq File.read(original_file.path)
    end
  end

  describe ".append_to_file" do
    it "appends multiple arguments" do
      file = File.tempfile do |io|
        io.puts "Line one\nLine two"
      end

      Spark::File.append_to_file(file.path, "One", "Two", "Woohoo")

      File.read(file.path).should eq "Line one\nLine two\nOneTwoWoohoo"
    end

    it "appends a block argument" do
      file = File.tempfile do |io|
        io.puts "Line one\nLine two"
      end

      Spark::File.append_to_file(file.path) do
        <<-CONTENT
        One
        Two
        Woohoo
        CONTENT
      end

      File.read(file.path).should eq "Line one\nLine two\nOne\nTwo\nWoohoo"
    end
  end

  describe ".prepend_to_file" do
    it "prepends multiple arguments" do
      file = File.tempfile do |io|
        io.puts "Line one\nLine two"
      end

      Spark::File.prepend_to_file(file.path, "One", "Two", "Woohoo\n")

      File.read(file.path).should eq "OneTwoWoohoo\nLine one\nLine two\n"
    end

    it "prepends a block argument" do
      file = File.tempfile do |io|
        io.puts "Line one\nLine two"
      end

      Spark::File.prepend_to_file(file.path) do
        <<-CONTENT
        One
        Two
        Woohoo\n
        CONTENT
      end

      File.read(file.path).should eq "One\nTwo\nWoohoo\nLine one\nLine two\n"
    end
  end

  describe ".inject_into_file" do
    it "injects multiple arguments" do
      file = File.tempfile do |io|
        io.puts "Line one\nLine two"
      end

      Spark::File.inject_into_file(file.path, "One", "Two", "Woohoo\n", before: /Line two\n/)

      File.read(file.path).should eq "Line one\nOneTwoWoohoo\nLine two\n"
    end

    context "with a before pattern" do
      it "works with a regex" do
        file = File.tempfile do |io|
          io.puts "Line one\nLine two"
        end

        Spark::File.inject_into_file(file.path, "Woohoo\n", before: /Line two\n/)

        File.read(file.path).should eq "Line one\nWoohoo\nLine two\n"
      end

      it "works with a string" do
        file = File.tempfile do |io|
          io.puts "Line one\nLine two"
        end

        Spark::File.inject_into_file(file.path, "Woohoo\n", before: "Line two\n")

        File.read(file.path).should eq "Line one\nWoohoo\nLine two\n"
      end

      it "works with a block" do
        file = File.tempfile do |io|
          io.puts "Line one\nLine two"
        end

        Spark::File.inject_into_file(file.path, before: /Line two\n/) do
          <<-CONTENT
          Woohoo!
          We've got new content!\n
          CONTENT
        end

        File.read(file.path).should eq "Line one\nWoohoo!\nWe've got new content!\nLine two\n"
      end
    end

    context "with an after pattern" do
      it "works with a regex" do
        file = File.tempfile do |io|
          io.puts "Line one\nLine two"
        end

        Spark::File.inject_into_file(file.path, "Woohoo\n", after: /Line one\n/)

        File.read(file.path).should eq "Line one\nWoohoo\nLine two\n"
      end

      it "works with a string" do
        file = File.tempfile do |io|
          io.puts "Line one\nLine two"
        end

        Spark::File.inject_into_file(file.path, "Woohoo\n", after: "Line one\n")

        File.read(file.path).should eq "Line one\nWoohoo\nLine two\n"
      end

      it "works with a block" do
        file = File.tempfile do |io|
          io.puts "Line one\nLine two"
        end

        Spark::File.inject_into_file(file.path, after: /Line one\n/) do
          <<-CONTENT
          Woohoo!
          We've got new content!\n
          CONTENT
        end

        File.read(file.path).should eq "Line one\nWoohoo!\nWe've got new content!\nLine two\n"
      end
    end
  end

  describe ".raise_unless_exists" do
    it "raises when a file does not exist" do
      expect_raises(ArgumentError) do
        Spark::File.raise_unless_exists("really_does_not_exist")
      end
    end

    it "does not raise when a file exists" do
      File.tempfile do |temp_file|
        Spark::File.raise_unless_exists(temp_file.path).should eq nil
      end
    end
  end
end
