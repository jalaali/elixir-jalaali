defmodule JalaaliTest do
  use ExUnit.Case
  import Jalaali
  doctest Jalaali

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "convert regular jalaali date to gregorian date" do
    test_time = DateTime.utc_now
    assert test_time == to_gregorian(to_jalaali(test_time))
  end

  test "method works with old dates" do
    test_time = ~D[2016-12-17]
    assert to_jalaali(test_time) == ~D[1395-09-27]
  end
end
