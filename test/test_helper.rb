require 'minitest/reporters'

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new(color: true)]

def require_src(path)
  require_relative "../src/#{path}"
end

# Temporarily suppress STDERR while tests run.
require 'stringio'
$stderr = StringIO.new
require 'minitest/autorun'
$stderr.string
