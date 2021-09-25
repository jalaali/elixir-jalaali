defmodule JalaaliTest do
  use ExUnit.Case
  import Jalaali
  doctest Jalaali
  doctest Jalaali.Calendar

  test "convert regular jalaali date to gregorian date" do
    test_time = DateTime.utc_now()
    assert test_time == to_gregorian(to_jalaali(test_time))
  end

  test "method works with old dates" do
    test_time = ~D[2016-12-17]
    assert to_jalaali(test_time) == ~D[1395-09-27]
  end

  test "First of JAN 2000 to jalaali" do
    {:ok, gre_date} = Date.new(2000, 1, 1)
    jal_date = Date.convert!(gre_date, Jalaali.Calendar)
    assert jal_date == %Date{calendar: Jalaali.Calendar, day: 11, month: 10, year: 1378}
  end

  test "Second of MAR 2150 to jalaali" do
    {:ok, gre_date} = Date.new(2150, 3, 2)
    jal_date = Date.convert!(gre_date, Jalaali.Calendar)
    assert jal_date == %Date{calendar: Jalaali.Calendar, day: 11, month: 12, year: 1528}
  end

  test "First of Farvardin 1350 to gregorian" do
    {:ok, jal_date} = Date.new(1350, 1, 1, Jalaali.Calendar)
    gre_date = Date.convert!(jal_date, Calendar.ISO)
    assert gre_date == %Date{calendar: Calendar.ISO, day: 21, month: 3, year: 1971}
  end

  test "11th of Bahaman 1371 to gregorian and vice versa" do
    {:ok, jal_date} = Date.new(1371, 11, 11, Jalaali.Calendar)
    gre_date = Date.convert!(jal_date, Calendar.ISO)
    assert gre_date == %Date{calendar: Calendar.ISO, day: 31, month: 1, year: 1993}
    assert jal_date == Date.convert!(gre_date, Jalaali.Calendar)
  end

  test "Fifth of Ordibehesht 1210 to gregorian" do
    {:ok, jal_date} = Date.new(1210, 2, 5, Jalaali.Calendar)
    gre_date = Date.convert!(jal_date, Calendar.ISO)
    assert gre_date == %Date{calendar: Calendar.ISO, day: 25, month: 4, year: 1831}
  end

  test "Current time conversion back and forth (Gregorian first)" do
    now_gre = DateTime.utc_now()
    gre_to_jal = DateTime.convert!(now_gre, Jalaali.Calendar)
    jal_to_gre = DateTime.convert!(gre_to_jal, Calendar.ISO)
    assert jal_to_gre == now_gre
  end

  test "Current time conversion back and forth (Jalaali first)" do
    now_jal = DateTime.utc_now(Jalaali.Calendar)
    jal_to_gre = DateTime.convert!(now_jal, Calendar.ISO)
    gre_to_jal = DateTime.convert!(jal_to_gre, Jalaali.Calendar)

    assert gre_to_jal == now_jal
  end

  test "Day number" do
    now = DateTime.utc_now()
    jal_now = DateTime.convert!(now, Jalaali.Calendar)

    assert Date.day_of_week(now) == Date.day_of_week(jal_now)
  end

  test "Day number in hundred days" do
    unix = DateTime.to_unix(DateTime.utc_now()) + 100 * 24 * 60 * 60

    now = DateTime.from_unix!(unix)
    jal_date = DateTime.convert!(now, Jalaali.Calendar)

    assert Date.day_of_week(now) == Date.day_of_week(jal_date)
  end

  test "Day number in hundred days ago" do
    unix = DateTime.to_unix(DateTime.utc_now()) - 100 * 24 * 60 * 60

    now = DateTime.from_unix!(unix)
    jal_date = DateTime.convert!(now, Jalaali.Calendar)

    assert Date.day_of_week(now) == Date.day_of_week(jal_date)
  end

  test "Day number on a specific date" do
    {:ok, now} = Date.new(1321, 7, 7, Jalaali.Calendar)

    assert Date.day_of_week(now) == 2
  end
end
