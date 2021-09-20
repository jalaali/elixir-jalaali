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


  def offset_to_string(utc, std, zone, format \\ :extended)
  def offset_to_string(0, 0, "Etc/UTC", _format), do: "Z"

  def offset_to_string(utc, std, _zone, format) do
    total = utc + std
    second = abs(total)
    minute = second |> rem(3600) |> div(60)
    hour = div(second, 3600)
    format_offset(total, hour, minute, format)
  end

  def format_offset(total, hour, minute, :extended) do
    sign(total) <> zero_pad(hour, 2) <> ":" <> zero_pad(minute, 2)
  end

  def format_offset(total, hour, minute, :basic) do
    sign(total) <> zero_pad(hour, 2) <> zero_pad(minute, 2)
  end

  def zone_to_string(0, 0, _abbr, "Etc/UTC"), do: ""
  def zone_to_string(_, _, abbr, zone), do: " " <> abbr <> " " <> zone

  def sign(total) when total < 0, do: "-"
  def sign(_), do: "+"

  def zero_pad(val, count) do
    num = Integer.to_string(val)
    :binary.copy("0", count - byte_size(num)) <> num
  end

  def div_mod(int1, int2) do
    div = div(int1, int2)
    mod = int1 - div * int2
    {div, mod}
  end
end
