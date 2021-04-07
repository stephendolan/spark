require "spec"
require "../src/spark"

# Force colorized output for all spec runs
# For example, this would be `false` in CI environments by default.
Colorize.enabled = true

# We suppress logger output during the test suite to keep things clean.
Spark.quiet = true
