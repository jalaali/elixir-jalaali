defmodule Jalaali.Calendar do
  @moduledoc """
  A calendar implementation based on jalaali calendar system
  """

  @behaviour Calendar

  @type year :: 0..9999
  @type month :: 1..12
  @type day :: 1..31

  @seconds_per_minute 60
  @seconds_per_hour 60 * 60
  @seconds_per_day 24 * 60 * 60 # Note that this does _not_ handle leap seconds.
  @microseconds_per_second 1_000_000

  @impl true
  @spec days_in_month(Calendar.year, Calendar.month) :: Calendar.day
  def days_in_month(year, month), do:
    Jalaali.jalaali_month_length(year, month)

  @impl true
  @spec leap_year?(Calendar.year) :: boolean
  def leap_year?(year), do:
    Jalaali.is_leap_jalaali_year(year)

  @impl true
  def day_of_week(year, month, day), do:
    Calendar.ISO.day_of_week(year, month, day)

  @doc """
  Converts the given date into a string.
  """
  @impl true
  def date_to_string(year, month, day) do
    zero_pad(year, 4) <> "-" <> zero_pad(month, 2) <> "-" <> zero_pad(day, 2)
  end

  def date_to_string(year, month, day, :extended), do:
    date_to_string(year, month, day)

  def date_to_string(year, month, day, :basic) do
    zero_pad(year, 4) <> zero_pad(month, 2) <> zero_pad(day, 2)
  end

  @doc """
  Converts the datetime (without time zone) into a string.
  """
  @impl true
  def naive_datetime_to_string(year, month, day, hour, minute, second, microsecond) do
   date_to_string(year, month, day) <> " " <> time_to_string(hour, minute, second, microsecond)
  end

  @doc """
  Convers the datetime (with time zone) into a string.
  """
  @impl true
  def datetime_to_string(year, month, day, hour, minute, second, microsecond,
                         time_zone, zone_abbr, utc_offset, std_offset) do
    date_to_string(year, month, day) <> " " <>
      time_to_string(hour, minute, second, microsecond) <>
      offset_to_string(utc_offset, std_offset, time_zone) <>
      zone_to_string(utc_offset, std_offset, zone_abbr, time_zone)
  end

  @doc """
  Converts the given time into a string.
  """
  @impl true
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
  @impl true
  @spec naive_datetime_to_iso_days(Calendar.year, Calendar.month, Calendar.day,
                                   Calendar.hour, Calendar.minute, Calendar.second,
                                   Calendar.microsecond) :: Calendar.iso_days
  def naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond) do
    {Jalaali.jalaali_to_days(year, month, day),
     time_to_day_fraction(hour, minute, second, microsecond)}
  end

  @doc """
  Converts the `t:Calendar.iso_days` format to the datetime format specified by this calendar.
  """
  @impl true
  @spec naive_datetime_from_iso_days(Calendar.iso_days) ::
        {Calendar.year, Calendar.month, Calendar.day,
         Calendar.hour, Calendar.minute, Calendar.second, Calendar.microsecond}
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
  @impl true
  @spec time_to_day_fraction(Calendar.hour, Calendar.minute,
                             Calendar.second, Calendar.microsecond) :: Calendar.day_fraction
  def time_to_day_fraction(0, 0, 0, {0, _}) do
    {0, 86400000000}
  end
  def time_to_day_fraction(hour, minute, second, {microsecond, _}) do
    combined_seconds = hour * @seconds_per_hour + minute * @seconds_per_minute + second
    {combined_seconds * @microseconds_per_second + microsecond, @seconds_per_day * @microseconds_per_second}
  end


  @doc """
  Converts a day fraction to this Calendar's representation of time.

  ## Examples
      iex> Calendar.ISO.time_from_day_fraction({1,2})
      {12, 0, 0, {0, 6}}
      iex> Calendar.ISO.time_from_day_fraction({13,24})
      {13, 0, 0, {0, 6}}

  """
  @impl true
  @spec time_from_day_fraction(Calendar.day_fraction) ::
        {Calendar.hour, Calendar.minute, Calendar.second, Calendar.microsecond}
  def time_from_day_fraction({parts_in_day, parts_per_day}) do
    total_microseconds = div(parts_in_day * @seconds_per_day * @microseconds_per_second, parts_per_day)
    {hours, rest_microseconds1} = div_mod(total_microseconds, @seconds_per_hour * @microseconds_per_second)
    {minutes, rest_microseconds2} = div_mod(rest_microseconds1, @seconds_per_minute * @microseconds_per_second)
    {seconds, microseconds} = div_mod(rest_microseconds2, @microseconds_per_second)
    {hours, minutes, seconds, {microseconds, 6}}
  end

  @doc """
  In Jalaali calendar new day starts at midnight.
  This function always returns `{0, 1}` as result.
  """
  @impl true
  def day_rollover_relative_to_midnight_utc(), do: {0, 1}

  @impl true
  def valid_date?(year, month, day), do:
    Jalaali.is_valid_jalaali_date?({year, month, day})

  @impl true
  def valid_time?(hour, minute, second, {microsecond, precision}) do
    hour in 0..23 and minute in 0..59 and second in 0..60 and
      microsecond in 0..999_999 and precision in 0..6
  end

  ###########
  # Helpers #
  ###########

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

  defp zone_to_string(0, 0, _abbr, "Etc/UTC"), do: ""
  defp zone_to_string(_, _, abbr, zone), do: " " <> abbr <> " " <> zone

  defp sign(total) when total < 0, do: "-"
  defp sign(_), do: "+"

  defp zero_pad(val, count) do
    num = Integer.to_string(val)
    :binary.copy("0", count - byte_size(num)) <> num
  end

  defp div_mod(int1, int2) do
    div = div(int1, int2)
    mod = int1 - (div * int2)
    {div, mod}
  end

end
