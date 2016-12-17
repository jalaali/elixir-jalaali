defmodule JalaaliTest do
  use ExUnit.Case
  import Jalaali
  doctest Jalaali

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "convert regular jalali to gregorian" do
    test_time = Timex.local
    assert test_time == to_gregorian(to_jalali(test_time))
  end

  test "method works with old dates" do
    test_time = ~D[0621-03-26]
    assert to_jalali(test_time) == ~D[0000-01-02]
  end
end
