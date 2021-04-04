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

Then get to work:

```crystal
prompt = Spark::Prompt.new

prompt.say "We're going to start our CLI, now", color: :yellow, style: :bold
user_name = prompt.ask "What is your name?"
prompt.say "Great, thank you #{user_name}.", color: :green
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
