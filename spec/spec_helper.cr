require "spec"
require "../src/spark"

# External libraries used for testing
require "webmock"

# Force colorized output for all spec runs
# For example, this would be `false` in CI environments by default.
Spec.before_each { Colorize.enabled = true }

# We suppress logger output during the test suite to keep things clean.
Spec.before_each { Spark.quiet = true }

# We ensure that each spec starts "clean" in terms of indentation.
Spec.before_each { Spark.reset_indentation }
