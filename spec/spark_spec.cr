require "./spec_helper"

describe Spark do
  describe ".indent" do
    it "correctly increases the indent level" do
      Spark.indent_level.should eq 0
      Spark.indent
      Spark.indent
      Spark.indent_level.should eq 2
    end
  end

  describe ".outdent" do
    it "correctly decreases the indent level" do
      Spark.indent
      Spark.indent
      Spark.outdent
      Spark.indent_level.should eq 1
    end

    it "does not permit an indentation level less than zero" do
      Spark.indent

      3.times do
        Spark.outdent
      end

      Spark.indent_level.should eq 0
    end
  end

  describe ".reset_indentation" do
    it "sets the indentation back to zero" do
      3.times do
        Spark.indent
      end

      Spark.reset_indentation
      Spark.indent_level.should eq 0
    end
  end
end
