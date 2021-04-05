# Spark

![Shard CI](https://github.com/stephendolan/spark/workflows/Shard%20CI/badge.svg)
[![API Documentation Website](https://img.shields.io/website?down_color=red&down_message=Offline&label=API%20Documentation&up_message=Online&url=https%3A%2F%2Fstephendolan.github.io%2Fspark%2F)](https://stephendolan.github.io/spark)
[![GitHub release](https://img.shields.io/github/release/stephendolan/spark.svg?label=Release)](https://github.com/stephendolan/spark/releases)

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  spark:
    github: stephendolan/spark
```

2. Run `shards install`

## Usage

Require the shard:

```crystal
require "spark"
```

### [Spark::Prompt](https://stephendolan.github.io/spark/Spark/Prompt.html)

```crystal
prompt = Spark::Prompt.new

prompt.say "We're going to start our CLI now.", color: :yellow, style: :bold
user_name = prompt.ask "What is your name?"

if prompt.yes? "Did you tell me the truth?"
  prompt.say "Great! Thank you, #{user_name}.", color: :green
else
  prompt.say "Shame on you!"
end

if prompt.no? "Are you feeling happy today?"
  prompt.say "I'm sorry to hear that."
else
  prompt.say "Then it's going to be a great day!"
end
```

### [Spark::File](https://stephendolan.github.io/spark/Spark/File.html)

```crystal
# Insert content before a given regular expression or string:
Spark::File.inject_into_file("src/app.cr", "require \"spark\"\n", before: /require "\./app_database"/)

# Insert content after a given regular expression or string:
Spark::File.inject_into_file("README.md", "# New Section", after: "# Last Section\n")

# Insert a block of content before a given regular expression or string:
Spark::File.inject_into_file("README.md", after: "# Last Section\n") do
  <<-CONTENT
  This is some new file content.
  It's going to be great!\n
  CONTENT
end

# Insert a block of content after a given regular expression or string:
Spark::File.inject_into_file("README.md", before: "# First Section\n") do
  <<-CONTENT
  This is some new file content.
  It's going to be great!\n
  CONTENT
end
```

## Development

1. Add your code
1. Ensure specs pass with `crystal spec`
1. Ensure correct formatting with `crystal tool format --check`
1. Ensure correct style with `./bin/ameba`

## Contributing

1. Fork it (<https://github.com/stephendolan/spark/fork>)
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request

## Credits & Inspirations

- [TTY](https://github.com/piotrmurach/tty)
- [Thor](https://github.com/erikhuda/thor)

## Contributors

- [Stephen Dolan](https://github.com/your-github-user) - creator and maintainer
