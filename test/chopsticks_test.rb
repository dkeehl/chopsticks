require "test_helper"

class ChopsticksTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Chopsticks::VERSION
  end
end
