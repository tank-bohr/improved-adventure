def find_missing(k, a)
  (1..k).to_a - a
end

require 'minitest/autorun'

class TestFindMissing < Minitest::Test
  def test_run
    k = 17
    missing = [5, 9]
    a = (1..k).to_a - missing

    result = find_missing(k, a)

    assert_equal(missing, result)
  end
end
