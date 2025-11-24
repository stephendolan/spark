require "../../spark"
require "option_parser"

module Spark::Cli
  extend self

  def run(args = ARGV)
    options = parse_arguments(args)

    case options.command
    when Command::Apply
      return unless templates = options.template_locations
      templates.each do |template_location|
        if options.local?
          Spark::Template.run_local_file(template_location)
        else
          Spark::Template.run_remote_file(template_location)
        end
      end
    end
  rescue exception
    puts "Error: #{exception.message}"
    exit 255
  end

  private class Opts
    property template_locations : Array(String)?
    property command : Command?
    property? local = false
  end

  private enum Command
    Apply
  end

  def parse_arguments(args, opts = Opts.new)
    OptionParser.parse(args) do |parser|
      parser.banner = "Usage: spark [subcommand]"

      parser.on("-v", "--version", "Print version") { print_version }
      parser.on("-h", "--help", "Show help") { print_help(parser) }

      parser.on("apply", "Apply a remote template") do
        parser.banner = "Usage: spark apply [flags] [template1 template2 ...]"
        opts.command = Command::Apply

        parser.on("-l", "--local", "Apply a local file instead of a remote URL") do
          opts.local = true
        end

        parser.unknown_args do |arguments|
          if arguments.empty?
            print_help(parser)
          end

          opts.template_locations = arguments
        end
      end

      print_help(parser) if args.empty?
    end

    opts
  end

  private def print_version
    puts VERSION
    exit 0
  end

  private def print_help(parser : OptionParser)
    puts parser
    exit 0
  end
end
