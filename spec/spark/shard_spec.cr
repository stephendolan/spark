require "../spec_helper"

describe Spark::Shard do
  describe ".add_shard" do
    context "with a development dependency" do
      context "when a `development_dependencies` section exists" do
        it "creates the expected shard file" do
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
                  branch: main
              CONTENT

            io.puts content
          end

          Spark::Shard.shard_file_path = file.path
          Spark::Shard.add_shard("testing", github: "testing/test", version: "~> 1.0.3", development_only: true)

          File.read(file.path).should eq <<-CONTENT
          name: spark
          version: x.x.x

          authors:
            - Test Author <testauthor@example.com>

          crystal: x.x.x

          license: MIT

          development_dependencies:
            testing:
              github: testing/test
              version: ~> 1.0.3
            spark:
              github: stephendolan/spark
              branch: main\n
          CONTENT
        end
      end

      context "when a `dependencies` section exists" do
        it "creates the expected shard file" do
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
                  branch: main
              CONTENT

            io.puts content
          end

          Spark::Shard.shard_file_path = file.path
          Spark::Shard.add_shard("testing", github: "testing/test", development_only: true)

          File.read(file.path).should eq <<-CONTENT
          name: spark
          version: x.x.x

          authors:
            - Test Author <testauthor@example.com>

          crystal: x.x.x

          license: MIT

          development_dependencies:
            testing:
              github: testing/test
            spark:
              github: stephendolan/spark
              branch: main\n
          CONTENT
        end
      end

      context "when both `dependencies` and `development_dependencies` sections exist" do
        it "creates the expected shard file" do
          file = File.tempfile do |io|
            content = <<-CONTENT
              name: spark
              version: x.x.x

              authors:
                - Test Author <testauthor@example.com>

              crystal: x.x.x

              license: MIT

              dependencies:
                lucky:
                  github: luckyframework/lucky
                  branch: main

              development_dependencies:
                spark:
                  github: stephendolan/spark
                  branch: main
              CONTENT

            io.puts content
          end

          Spark::Shard.shard_file_path = file.path
          Spark::Shard.add_shard("testing", github: "testing/test", development_only: true)

          File.read(file.path).should eq <<-CONTENT
          name: spark
          version: x.x.x

          authors:
            - Test Author <testauthor@example.com>

          crystal: x.x.x

          license: MIT

          dependencies:
            lucky:
              github: luckyframework/lucky
              branch: main

          development_dependencies:
            testing:
              github: testing/test
            spark:
              github: stephendolan/spark
              branch: main\n
          CONTENT
        end
      end

      context "when there are no dependencies" do
        it "creates the expected shard file" do
          file = File.tempfile do |io|
            content = <<-CONTENT
              name: spark
              version: x.x.x

              authors:
                - Test Author <testauthor@example.com>

              crystal: x.x.x

              license: MIT
              CONTENT

            io.puts content
          end

          Spark::Shard.shard_file_path = file.path
          Spark::Shard.add_shard("testing", github: "testing/test", development_only: true)

          File.read(file.path).should eq <<-CONTENT
          name: spark
          version: x.x.x

          authors:
            - Test Author <testauthor@example.com>

          crystal: x.x.x

          license: MIT

          development_dependencies:
            testing:
              github: testing/test\n
          CONTENT
        end
      end
    end

    context "with a production dependency" do
      context "when a `development_dependencies` section exists" do
        it "creates the expected shard file" do
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
                  branch: main
              CONTENT

            io.puts content
          end

          Spark::Shard.shard_file_path = file.path
          Spark::Shard.add_shard("testing", github: "testing/test")

          File.read(file.path).should eq <<-CONTENT
          name: spark
          version: x.x.x

          authors:
            - Test Author <testauthor@example.com>

          crystal: x.x.x

          license: MIT

          dependencies:
            testing:
              github: testing/test

          development_dependencies:
            spark:
              github: stephendolan/spark
              branch: main\n
          CONTENT
        end
      end

      context "when a `dependencies` section exists" do
        it "creates the expected shard file" do
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
                  branch: main
              CONTENT

            io.puts content
          end

          Spark::Shard.shard_file_path = file.path
          Spark::Shard.add_shard("testing", github: "testing/test")

          File.read(file.path).should eq <<-CONTENT
          name: spark
          version: x.x.x

          authors:
            - Test Author <testauthor@example.com>

          crystal: x.x.x

          license: MIT

          dependencies:
            testing:
              github: testing/test
            spark:
              github: stephendolan/spark
              branch: main\n
          CONTENT
        end
      end

      context "when both `dependencies` and `development_dependencies` sections exist" do
        it "creates the expected shard file" do
          file = File.tempfile do |io|
            content = <<-CONTENT
              name: spark
              version: x.x.x

              authors:
                - Test Author <testauthor@example.com>

              crystal: x.x.x

              license: MIT

              dependencies:
                lucky:
                  github: luckyframework/lucky
                  branch: main

              development_dependencies:
                spark:
                  github: stephendolan/spark
                  branch: main
              CONTENT

            io.puts content
          end

          Spark::Shard.shard_file_path = file.path
          Spark::Shard.add_shard("testing", github: "testing/test")

          File.read(file.path).should eq <<-CONTENT
          name: spark
          version: x.x.x

          authors:
            - Test Author <testauthor@example.com>

          crystal: x.x.x

          license: MIT

          dependencies:
            testing:
              github: testing/test
            lucky:
              github: luckyframework/lucky
              branch: main

          development_dependencies:
            spark:
              github: stephendolan/spark
              branch: main\n
          CONTENT
        end
      end

      context "when there are no dependencies" do
        it "creates the expected shard file" do
          file = File.tempfile do |io|
            content = <<-CONTENT
              name: spark
              version: x.x.x

              authors:
                - Test Author <testauthor@example.com>

              crystal: x.x.x

              license: MIT
              CONTENT

            io.puts content
          end

          Spark::Shard.shard_file_path = file.path
          Spark::Shard.add_shard("testing", github: "testing/test")

          File.read(file.path).should eq <<-CONTENT
          name: spark
          version: x.x.x

          authors:
            - Test Author <testauthor@example.com>

          crystal: x.x.x

          license: MIT

          dependencies:
            testing:
              github: testing/test\n
          CONTENT
        end
      end
    end
  end
end
