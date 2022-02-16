require "spec"
require "../src/spark"

# External libraries used for testing
require "webmock"

# Set a test environment variable so that local "spark" requires in template.cr will work
ENV["SPARK_TEST"] = "true"

# Force colorized output for all spec runs
# For example, this would be `false` in CI environments by default.
Spec.before_each { Colorize.enabled = true }

# We suppress logger output during the test suite to keep things clean.
Spec.before_each { Spark.quiet = true }

# We ensure that each spec starts "clean" in terms of indentation.
Spec.before_each { Spark.reset_indentation }
