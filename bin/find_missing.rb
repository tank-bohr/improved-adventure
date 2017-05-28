#!/usr/bin/env ruby

def find_missing(from, to, list)
  n = to - from
  ref_sum = (n + 1) * (2 * from + n) / 2
  real_sum = list.reduce(:+)
  ref_sum - real_sum
end

def binary_search(from, to, list)
  mid_idx = list.length / 2 - 1
  ref_elem = from + mid_idx
  real_elem = list[mid_idx]
  left = list[0..mid_idx]
  right = list[mid_idx + 1..-1]
  if real_elem == ref_elem
    1 == right.length ?
      process_edge(right.first, to) :
      binary_search(real_elem + 1, to, right)
  elsif real_elem == ref_elem + 1
    [
      find_missing(from, real_elem, left),
      find_missing(real_elem + 1, to, right),
    ]
  elsif real_elem == ref_elem + 2
    1 == left.length ?
      process_edge(left.first, from) :
      binary_search(from, real_elem, left)
  else
    raise "Bad arguments"
  end
end

def process_edge(elem, edge)
  if elem >= edge
    [elem - 2, elem - 1]
  else
    [elem + 1, elem + 2]
  end
end


require 'minitest/autorun'

class TestFindMissing < MiniTest::Unit::TestCase
  def test_find_missing
    assert_equal(5,  find_missing(1, 10, [1, 2, 3, 4, 6, 7, 8, 9, 10]))
    assert_equal(1,  find_missing(1, 10, [2, 3, 4, 5, 6, 7, 8, 9, 10]))
    assert_equal(10, find_missing(1, 10, [1, 2, 3, 4, 5, 6, 7, 8, 9]))
    assert_equal(7,  find_missing(5, 10, [5, 6, 8, 9, 10]))
  end

  def test_binary_search
    from = 1
    to = 100
    [
      [1, 2],
      [99, 100],
      [21, 22],
      [25, 75]
    ].each do |exclude|
      list = from.upto(to).to_a - exclude
      assert_equal(exclude, binary_search(from, to, list))
    end
  end
end
