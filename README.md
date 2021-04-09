# Spark

![Shard CI](https://github.com/stephendolan/spark/workflows/Shard%20CI/badge.svg)
[![API Documentation Website](https://img.shields.io/website?down_color=red&down_message=Offline&label=API%20Documentation&up_message=Online&url=https%3A%2F%2Fstephendolan.github.io%2Fspark%2F)](https://stephendolan.github.io/spark)
[![GitHub release](https://img.shields.io/github/release/stephendolan/spark.svg?label=Release)](https://github.com/stephendolan/spark/releases)

## Installation

Add the dependency to your `shard.yml`:

```yaml
dependencies:
  spark:
    github: stephendolan/spark
```

Run `shards install`

## Usage

Require the shard:

```crystal
require "spark"
```

Then, use any of the fully documented modules below to interact with your user:

- 💬 &nbsp; **[Spark::Prompt](https://stephendolan.github.io/spark/Spark/Prompt.html)**
  - [`#say`](<https://stephendolan.github.io/spark/Spark/Prompt.html#say(message:String=%22%22,**options)-instance-method>) - Display a message to a user
  - [`#ask`](<https://stephendolan.github.io/spark/Spark/Prompt.html#ask(message:String,**options)-instance-method>) - Get information from a user
  - [`#yes?`](<https://stephendolan.github.io/spark/Spark/Prompt.html#yes?(message:String,**options)-instance-method>) - Get confirmation from a user, with a default of "Yes"
  - [`#no?`](<https://stephendolan.github.io/spark/Spark/Prompt.html#no?(message:String,**options)-instance-method>) - Get confirmation from a user, with a default of "No"
  - [`#newline`](https://stephendolan.github.io/spark/Spark/Prompt.html#newline) - Output a blank line to the user's prompt
- 🗄 &nbsp; **[Spark::File](https://stephendolan.github.io/spark/Spark/File.html)**
  - [`.replace_in_file`](<https://stephendolan.github.io/spark/Spark/File.html#replace_in_file(relative_path:String,pattern:Regex%7CString,replacement:String)-instance-method>) - Replace some content in a file
  - [`.inject_into_file`](<https://stephendolan.github.io/spark/Spark/File.html#inject_into_file(relative_path:String,*content,afterpattern:Regex%7CString)-instance-method>) - Insert content into a file before or after a pattern
  - [`.prepend_to_file`](<https://stephendolan.github.io/spark/Spark/File.html#prepend_to_file(relative_path:String,*content)-instance-method>) - Insert content at the beginning of a file
  - [`.append_to_file`](<https://stephendolan.github.io/spark/Spark/File.html#append_to_file(relative_path:String,*content)-instance-method>) - Insert content at the end of a file
  - [`.copy_file`](<https://stephendolan.github.io/spark/Spark/File.html#copy_file(source_path:String,destination_path:String):String-instance-method>) - Copy a file (very few safeguards in place currently)
  - [`.create_file`](<https://stephendolan.github.io/spark/Spark/File.html#create_file(relative_path:String,*content):String-instance-method>) - Create a file (very few safeguards in place currently)
  - [`.remove_file`](<https://stephendolan.github.io/spark/Spark/File.html#remove_file(relative_path:String)-instance-method>) - Remove a file
- 💎 &nbsp; **[Spark::Shard](https://stephendolan.github.io/spark/Spark/Shard.html)**
  - [`#add_shard`](<https://stephendolan.github.io/spark/Spark/Shard.html#add_shard(name:String,*,development_only:Bool=false,**options)-instance-method>) - Adds a shard to the `shard.yml` file

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
