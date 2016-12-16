defmodule Jalali do
  @moduledoc """
  The Jalali calendar is a solar calendar that was used in Persia and Afganistan.
  This module can convert gregorian datetimes to jalali datetimes and vice versa.
  """

  @doc """
  Converts a jalali date to its equivalent in gregorian calendar
  """
  @spec to_gregorian(DateTime.t) :: DateTime.t
  def to_gregorian(datetime) do
    Timex.add(datetime, Timex.Duration.from_days(226899))
  end

  @doc """
  Converts a gregorian date to its equivalent in jalali calendar
  """
  def to_jalali(datetime) do
    Timex.add(datetime, Timex.Duration.from_days(-226899))
  end
end
