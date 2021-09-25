defmodule Jalaali.Calendar do
  @moduledoc """
  A calendar implementation based on jalaali calendar system
  """
  @seconds_per_minute 60
  @seconds_per_hour 60 * 60
  # Note that this does NOT handle leap seconds.
  @seconds_per_day 24 * 60 * 60
  @microseconds_per_second 1_000_000
  @months_in_year 12
  # The Jalaali epoch starts, in this implementation,
  # with era 1 on 0001-01-01 which is 227261 days later.
  @jalaali_epoch 227_261

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

  @spec days_in_month(year(), month()) :: day()
  def days_in_month(year, month), do: Jalaali.jalaali_month_length(year, month)

  @spec leap_year?(year()) :: boolean()
  def leap_year?(year), do: Jalaali.is_leap_jalaali_year(year)

  @doc """
  Returns day of week on a spesific set of year, month and day
  """
  @spec day_of_week(integer,pos_integer,pos_integer, atom()) :: tuple() | {1 | 2 | 3 | 4 | 5 | 6 | 7, 1, 7}
  if Code.ensure_loaded?(Calendar.ISO) && function_exported?(Calendar.ISO, :day_of_week, 4) do
    def day_of_week(year, month, day, starting_on) do
      {:ok, date} = Date.new(year, month, day, __MODULE__)
      iso_date = Date.convert!(date, Calendar.ISO)
      Calendar.ISO.day_of_week(iso_date.year, iso_date.month, iso_date.day, starting_on)
    end
  else
    def day_of_week(year, month, day) do
      {:ok, date} = Date.new(year, month, day, __MODULE__)
      iso_date = Date.convert!(date, Calendar.ISO)
      Calendar.ISO.day_of_week(iso_date.year, iso_date.month, iso_date.day)
    end
  end

  @doc """
  Converts the given date into a string.
  """
  @spec date_to_string(year(), month(), day()) :: String.t()
  def date_to_string(year, month, day) do
    zero_pad(year, 4) <> "-" <> zero_pad(month, 2) <> "-" <> zero_pad(day, 2)
  end

  @doc """
  Converts a Date struct to string human readable format

   - Extended type of string date. e.g.: "2017-01-05" `:extended`
   - Basic type of string date. e.g.: "20170105" `:basic`
  """
  @spec date_to_string(year(), month(), day(), :extended | :basic) :: String.t()
  def date_to_string(year, month, day, :extended), do: date_to_string(year, month, day)

  def date_to_string(year, month, day, :basic) do
    zero_pad(year, 4) <> zero_pad(month, 2) <> zero_pad(day, 2)
  end

  @doc """
  Converts the datetime (without time zone) into a human readable string.
  """
  @spec naive_datetime_to_string(year(), month(), day(), hour(), minute(), second(), microsecond) :: nonempty_binary
  def naive_datetime_to_string(year, month, day, hour, minute, second, microsecond) do
    date_to_string(year, month, day) <> " " <> time_to_string(hour, minute, second, microsecond)
  end

  @doc """
  Convers the datetime (with time zone) into a human readable string.
  """
  @spec datetime_to_string(integer(), integer(), integer(), integer(), integer(), integer(), {any, integer()}, binary, any, number, number) :: nonempty_binary
  def datetime_to_string(year, month, day, hour, minute, second, microsecond, time_zone, zone_abbr, utc_offset, std_offset) do
    date_to_string(year, month, day) <>
      " " <>
      time_to_string(hour, minute, second, microsecond) <>
      offset_to_string(utc_offset, std_offset, time_zone) <>
      zone_to_string(utc_offset, std_offset, zone_abbr, time_zone)
  end

  @doc """
  Converts the given time into a string.
  """
  @spec time_to_string(integer(), integer(), integer(), {any, integer()}) :: binary
  def time_to_string(hour, minute, second, microsecond) do
    time_to_string(hour, minute, second, microsecond, :extended)
  end

  def time_to_string(hour, minute, second, {_, 0}, format) do
    time_to_string_format(hour, minute, second, format)
  end

  def time_to_string(hour, minute, second, {microsecond, precision}, format) do
    time_to_string_format(hour, minute, second, format) <>
      "." <> (microsecond |> zero_pad(6) |> binary_part(0, precision))
  end

  defp time_to_string_format(hour, minute, second, :extended) do
    zero_pad(hour, 2) <> ":" <> zero_pad(minute, 2) <> ":" <> zero_pad(second, 2)
  end

  defp time_to_string_format(hour, minute, second, :basic) do
    zero_pad(hour, 2) <> zero_pad(minute, 2) <> zero_pad(second, 2)
  end

  @doc """
  Returns the `t:Calendar.iso_days` format of the specified date.
  """
  @spec naive_datetime_to_iso_days(year(), month(), day(), hour(), minute(), second(), microsecond()) :: iso_days()
  def naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond) do
    {Jalaali.jalaali_to_days(year, month, day),
     time_to_day_fraction(hour, minute, second, microsecond)}
  end

  @doc """
  Converts the `t:Calendar.iso_days` format to the datetime format specified by this calendar.
  """
  @spec naive_datetime_from_iso_days(iso_days()) :: {year(), month(), day(), hour(), minute(), second(), microsecond()}
  def naive_datetime_from_iso_days({days, day_fraction}) do
    {year, month, day} = Jalaali.days_to_jalaali(days)
    {hour, minute, second, microsecond} = time_from_day_fraction(day_fraction)
    {year, month, day, hour, minute, second, microsecond}
  end

  @doc """
  Returns the normalized day fraction of the specified time.

  ## Examples
      iex> Calendar.ISO.time_to_day_fraction(0, 0, 0, {0, 6})
      {0, 86400000000}
      iex> Calendar.ISO.time_to_day_fraction(12, 34, 56, {123, 6})
      {45296000123, 86400000000}

  """

  @spec time_to_day_fraction(number, number, number, {number, any}) :: {number, 86_400_000_000}
  def time_to_day_fraction(0, 0, 0, {0, _}) do
    {0, 86_400_000_000}
  end

  def time_to_day_fraction(hour, minute, second, {microsecond, _}) do
    combined_seconds = hour * @seconds_per_hour + minute * @seconds_per_minute + second

    {combined_seconds * @microseconds_per_second + microsecond,
     @seconds_per_day * @microseconds_per_second}
  end

  @doc """
  Converts a day fraction to this Calendar's representation of time.

  ## Examples
      iex> Calendar.ISO.time_from_day_fraction({1,2})
      {12, 0, 0, {0, 6}}
      iex> Calendar.ISO.time_from_day_fraction({13,24})
      {13, 0, 0, {0, 6}}

  """
  @spec time_from_day_fraction(day_fraction()) :: {hour(), minute(), second(), microsecond()}
  def time_from_day_fraction({parts_in_day, parts_per_day}) do
    total_microseconds =
      div(parts_in_day * @seconds_per_day * @microseconds_per_second, parts_per_day)

    {hours, rest_microseconds1} =
      div_mod(total_microseconds, @seconds_per_hour * @microseconds_per_second)

    {minutes, rest_microseconds2} =
      div_mod(rest_microseconds1, @seconds_per_minute * @microseconds_per_second)

    {seconds, microseconds} = div_mod(rest_microseconds2, @microseconds_per_second)
    {hours, minutes, seconds, {microseconds, 6}}
  end

  @doc """
  In Jalaali calendar new day starts at midnight.
  This function always returns `{0, 1}` as result.
  """
  def day_rollover_relative_to_midnight_utc(), do: {0, 1}

  def valid_date?(year, month, day), do: Jalaali.is_valid_jalaali_date?({year, month, day})

  def valid_time?(hour, minute, second, {microsecond, precision}) do
    hour in 0..23 and minute in 0..59 and second in 0..60 and
      microsecond in 0..999_999 and precision in 0..6
  end

  @doc """
  Calculates the year and era from the given `year`.

  The Jalaali calendar has two eras: the current era which
  starts in year 1 and is defined as era `1`. and a second
  era for those years less than 1 defined as era `0`.

  ## Examples

      iex> Jalaali.Calendar.year_of_era(1)
      {1, 1}
      iex> Jalaali.Calendar.year_of_era(1398)
      {1398, 1}
      iex> Jalaali.Calendar.year_of_era(0)
      {1, 0}
      iex> Jalaali.Calendar.year_of_era(-1)
      {2, 0}
  """
  @spec year_of_era(year) :: {year(), era :: 0..1}
  def year_of_era(year) when is_integer(year) and year > 0, do: {year, 1}

  def year_of_era(year) when is_integer(year) and year < 1, do: {abs(year) + 1, 0}

  @doc """
  Returns how many months there are in the given year.

  It's always 12 for Jalaali calendar system.

  ## Examples

      iex> Jalaali.Calendar.months_in_year(1398)
      12

  """
  @spec months_in_year(year) :: 12
  def months_in_year(_year), do: @months_in_year

  @doc """
  Calculates the quarter of the year from the given `year`, `month`, and `day`.
  It is an integer from 1 to 4.
  ## Examples
      iex> Jalaali.Calendar.quarter_of_year(1398, 1, 31)
      1
      iex> Jalaali.Calendar.quarter_of_year(123, 4, 3)
      2
      iex> Jalaali.Calendar.quarter_of_year(-61, 9, 31)
      3
      iex> Jalaali.Calendar.quarter_of_year(2678, 12, 28)
      4
  """
  @spec quarter_of_year(year, month, day) :: 1..4
  def quarter_of_year(year, month, day)
      when is_integer(year) and is_integer(month) and is_integer(day) do
    div(month - 1, 3) + 1
  end

  @doc """
  Calculates the day and era from the given `year`, `month`, and `day`.
  ## Examples
      iex> Jalaali.Calendar.day_of_era(0, 1, 1)
      {366, 0}
      iex> Jalaali.Calendar.day_of_era(1, 1, 1)
      {1, 1}
      iex> Jalaali.Calendar.day_of_era(0, 12, 30)
      {1, 0}
      iex> Jalaali.Calendar.day_of_era(0, 12, 29)
      {2, 0}
      iex> Jalaali.Calendar.day_of_era(-1, 12, 29)
      {367, 0}
  """
  @spec day_of_era(year, month, day) :: {day :: pos_integer(), era :: 0..1}
  def day_of_era(year, month, day)
      when is_integer(year) and is_integer(month) and is_integer(day) and year > 0 do
    day = Jalaali.jalaali_to_days(year, month, day) - @jalaali_epoch + 1
    {day, 1}
  end

  def day_of_era(year, month, day)
      when is_integer(year) and is_integer(month) and is_integer(day) and year < 1 do
    day = abs(Jalaali.jalaali_to_days(year, month, day) - @jalaali_epoch)
    {day, 0}
  end

  @doc """
  Calculates the day of the year from the given `year`, `month`, and `day`.
  It is an integer from 1 to 366.

  ## Examples

      iex> Jalaali.Calendar.day_of_year(1398, 1, 31)
      31
      iex> Jalaali.Calendar.day_of_year(-61, 2, 1)
      32
      iex> Jalaali.Calendar.day_of_year(1397, 2, 28)
      59

  """
  @spec day_of_year(year, month, day) :: 1..366
  def day_of_year(year, month, day)
      when is_integer(year) and is_integer(month) and is_integer(day) do
    first_day_of_year = Jalaali.jalaali_to_days(year, 01, 01)
    Jalaali.jalaali_to_days(year, month, day) - first_day_of_year + 1
  end

  ###########
  # Helpers #
  ###########

  @spec offset_to_string(number, number, any, any) :: binary
  defp offset_to_string(utc, std, zone, format \\ :extended)
  defp offset_to_string(0, 0, "Etc/UTC", _format), do: "Z"

  defp offset_to_string(utc, std, _zone, format) do
    total = utc + std
    second = abs(total)
    minute = second |> rem(3600) |> div(60)
    hour = div(second, 3600)
    format_offset(total, hour, minute, format)
  end


  defp format_offset(total, hour, minute, :extended) do
    sign(total) <> zero_pad(hour, 2) <> ":" <> zero_pad(minute, 2)
  end

  defp format_offset(total, hour, minute, :basic) do
    sign(total) <> zero_pad(hour, 2) <> zero_pad(minute, 2)
  end

  @spec zone_to_string(any, any, any, binary) :: binary
  defp zone_to_string(0, 0, _abbr, "Etc/UTC"), do: ""
  defp zone_to_string(_, _, abbr, zone), do: " " <> abbr <> " " <> zone

  defp sign(total) when total < 0, do: "-"
  defp sign(_), do: "+"

  @spec zero_pad(integer, non_neg_integer) :: binary
  defp zero_pad(val, count) do
    num = Integer.to_string(val)
    :binary.copy("0", count - byte_size(num)) <> num
  end

  @spec div_mod(integer, integer) :: {integer, integer}
  defp div_mod(int1, int2) do
    div = div(int1, int2)
    mod = int1 - div * int2
    {div, mod}
  end
end
