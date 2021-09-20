defmodule Jalaali.Helper do

  @type year :: neg_integer() | integer()
  @type month :: pos_integer
  @type day :: pos_integer
  @type day_of_week :: pos_integer
  @type hour :: integer()
  @type minute :: integer()
  @type second :: integer()
  @type microsecond :: integer() | {integer, integer}
  @type day_fraction :: {parts_in_day :: non_neg_integer, parts_per_day :: pos_integer}
  @type iso_days :: {days :: integer, day_fraction}

  @callback days_in_month(year(), month()) :: day()
  @callback leap_year?(year()) :: boolean()
  @callback day_of_week(integer,pos_integer,pos_integer, atom()) :: tuple() | {1 | 2 | 3 | 4 | 5 | 6 | 7, 1, 7}
  @callback date_to_string(year(), month(), day()) :: String.t()
  @callback date_to_string(year(), month(), day(), :extended | :basic) :: String.t()
  @callback naive_datetime_to_string(year(), month(), day(), hour(), minute(), second(), microsecond) :: nonempty_binary
  @callback datetime_to_string(integer(), integer(), integer(), integer(), integer(), integer(), {any, integer()}, binary, any, number, number) :: nonempty_binary
  @callback time_to_string(integer(), integer(), integer(), {any, integer()}) :: binary
  @callback naive_datetime_to_iso_days(year(), month(), day(), hour(), minute(), second(), microsecond()) :: iso_days()
  @callback naive_datetime_from_iso_days(iso_days()) :: {year(), month(), day(), hour(), minute(), second(), microsecond()}
  @callback time_to_day_fraction(number, number, number, {number, any}) :: {number, 86_400_000_000}
  @callback time_from_day_fraction(day_fraction()) :: {hour(), minute(), second(), microsecond()}
  @callback year_of_era(year) :: {year(), era :: 0..1}
  @callback months_in_year(year) :: 12
  @callback quarter_of_year(year, month, day) :: 1..4
  @callback day_of_era(year, month, day) :: {day :: pos_integer(), era :: 0..1}
  @callback day_of_year(year, month, day) :: 1..366


  @spec offset_to_string(number, number, any, any) :: binary
  def offset_to_string(utc, std, zone, format \\ :extended)
  def offset_to_string(0, 0, "Etc/UTC", _format), do: "Z"

  def offset_to_string(utc, std, _zone, format) do
    total = utc + std
    second = abs(total)
    minute = second |> rem(3600) |> div(60)
    hour = div(second, 3600)
    format_offset(total, hour, minute, format)
  end

  @spec format_offset(any, integer, integer, :basic | :extended) :: binary
  def format_offset(total, hour, minute, :extended) do
    sign(total) <> zero_pad(hour, 2) <> ":" <> zero_pad(minute, 2)
  end

  def format_offset(total, hour, minute, :basic) do
    sign(total) <> zero_pad(hour, 2) <> zero_pad(minute, 2)
  end

  @spec zone_to_string(any, any, any, binary) :: binary
  def zone_to_string(0, 0, _abbr, "Etc/UTC"), do: ""
  def zone_to_string(_, _, abbr, zone), do: " " <> abbr <> " " <> zone

  def sign(total) when total < 0, do: "-"
  def sign(_), do: "+"

  @spec zero_pad(integer, non_neg_integer) :: binary
  def zero_pad(val, count) do
    num = Integer.to_string(val)
    :binary.copy("0", count - byte_size(num)) <> num
  end

  @spec div_mod(integer, integer) :: {integer, integer}
  def div_mod(int1, int2) do
    div = div(int1, int2)
    mod = int1 - div * int2
    {div, mod}
  end


  # Helper functions to create a custom Jalaali time to input on HTML source
  @spec miladi_to_jalaali(map()) :: binary
  def miladi_to_jalaali(datetime) do
    {:ok, jalaali_datetime} = DateTime.convert(datetime, Jalaali.Calendar)
    jalaali_datetime
    |> DateTime.to_string()
    |> String.replace("Z", "")
  end

  @spec jalaali_create(map(), binary()) :: %{day_number: pos_integer, month_name: pos_integer, year_number: integer}
  def jalaali_create(time_need, "number") do
    {:ok, jalaali_date} = Date.convert(time_need, Jalaali.Calendar)
    %{day_number: jalaali_date.day, month_name: jalaali_date.month, year_number: jalaali_date.year}
  end

  @spec jalaali_create(map()) :: %{day_number: pos_integer, month_name: String.t(), year_number: integer}
  def jalaali_create(time_need) do
    {:ok, jalaali_date} = Date.convert(time_need, Jalaali.Calendar)
    %{day_number: jalaali_date.day, month_name: get_month(jalaali_date.month), year_number: jalaali_date.year}
  end

  @spec get_month(integer()) :: String.t()
  def get_month(id) when id in 1..12 do
    {_id, name} = [
      {1, "فروردین"}, {2, "اردیبهشت"}, {3, "خرداد"}, {4, "تیر"}, {5, "مرداد"}, {6, "شهریور"},
      {7, "مهر"}, {8, "آبان"}, {9, "آذر"}, {10, "دی"}, {11, "بهمن"}, {12, "اسفند"},
    ]
    |> Enum.find(fn {month_id, _month_persian_name} -> month_id == id end)
    name
  end
end
