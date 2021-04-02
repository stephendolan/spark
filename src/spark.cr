require "./spark/*"

# Spark is a CLI Utility library that makes working with users on the
# command line simpler than ever.
module Spark
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}
end
