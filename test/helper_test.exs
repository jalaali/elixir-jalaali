defmodule HelperliTest do
  use ExUnit.Case
  doctest Jalaali
  alias Jalaali.Helper

  describe "Happy way | Jalaali Helper functions (▰˘◡˘▰)" do
    test "Miladi to jalaali" do
      utc_time = ~U[1993-01-31 10:01:44.653462Z]
      "1371-11-12 10:01:44.653462" = assert Helper.miladi_to_jalaali(utc_time)
    end

    test "Create Jalaali" do
      utc_time = ~U[1993-01-31 10:01:44.653462Z]
      %{day_number: 12, month_name: "بهمن", year_number: 1371} = assert Helper.jalaali_create(utc_time)
    end
  end
end
