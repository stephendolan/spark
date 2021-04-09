require "spec"
require "../src/spark"

# Force colorized output for all spec runs
# For example, this would be `false` in CI environments by default.
Spec.before_each { Colorize.enabled = true }

# We suppress logger output during the test suite to keep things clean.
Spec.before_each { Spark.quiet = true }
