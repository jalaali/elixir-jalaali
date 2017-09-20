defmodule Jalaali.Calendar do
  @moduledoc """
  A calendar implementation based on jalaali calendar system
  """

  @behaviour Calendar

  @unix_epoch 62167219200
  @unix_start 1_000_000 * -@unix_epoch
  @unix_end 1_000_000 * (315569519999 - @unix_epoch)
  @unix_range_microseconds @unix_start..@unix_end

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
  @spec leap_year(Calendar.year) :: boolean
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

  @impl true
  def date_to_string(year, month, day, :extended), do:
    date_to_string(year, month, day)

  @impl true
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
  def time_to_string(hour, minute, second, microsecond, format \\ :extended)

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
  ## Examples
      iex> Calendar.ISO.naive_datetime_to_iso_days(0, 1, 1, 0, 0, 0, {0, 6})
      {0, {0, 86400000000}}
      iex> Calendar.ISO.naive_datetime_to_iso_days(2000, 1, 1, 12, 0, 0, {0, 6})
      {730485, {43200000000, 86400000000}}
      iex> Calendar.ISO.naive_datetime_to_iso_days(2000, 1, 1, 13, 0, 0, {0, 6})
      {730485, {46800000000, 86400000000}}
  """
  @spec naive_datetime_to_iso_days(Calendar.year, Calendar.month, Calendar.day,
                                   Calendar.hour, Calendar.minute, Calendar.second,
                                   Calendar.microsecond) :: Calendar.iso_days
  def naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond) do
    {date_to_iso_days_days(year, month, day),
     time_to_day_fraction(hour, minute, second, microsecond)}
  end

  # TODO: Implement other callbacks

  defp zero_pad(val, count) do
    num = Integer.to_string(val)
    :binary.copy("0", count - byte_size(num)) <> num
  end

end
