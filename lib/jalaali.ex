defmodule Jalaali do
  @moduledoc """
  Jalaali module helps converting gregorian dates to jalaali dates.
  Jalaali calendar is widely used in Persia and Afganistan.

  This module helps you with converting erlang and/or elixir DateTime formats to Jalaali date (and vice versa) and checking for leap years
  """

  @days_offset 1_721_060
  @breaks [
    -61,
    9,
    38,
    199,
    426,
    686,
    756,
    818,
    1111,
    1181,
    1210,
    1635,
    2060,
    2097,
    2192,
    2262,
    2324,
    2394,
    2456,
    3178
  ]

  @doc """
  Converts erlang or elixir date or dateTime from Gregorian to Jalaali format

  ## Parameters
    - arg1: Date to convert in erlang format (a tuple with three elements)
    - arg1: erlang dateTime to convert in erlang format (a tuple with two difftent tuples each with 3 elements)
    - ex_dt: Date or DateTime to convert

  ## Exmaples
  ```elixir
  iex> Jalaali.to_jalaali {2016, 12, 17}
  {1395, 9, 27}

  iex> Jalaali.to_jalaali {{2016, 12, 17}, {11, 11, 11}}
  {{1395, 9, 27}, {11, 11, 11}}

  iex> Jalaali.to_jalaali ~D[2016-12-17]
  ~D[1395-09-27]
  ```
  """
  @spec to_jalaali(tuple() | DateTime.t() | Date.t()) :: tuple() | DateTime.t() | Date.t()
  def to_jalaali({gy, gm, gd}) do
    d2j(g2d({gy, gm, gd}))
  end

  def to_jalaali({date, time}) do
    {to_jalaali(date), time}
  end

  def to_jalaali(ex_dt) do
    {jy, jm, jd} = to_jalaali({ex_dt.year, ex_dt.month, ex_dt.day})
    %{ex_dt | year: jy, month: jm, day: jd}
  end

  @doc """
  Converts erlang or elixir date or dateTime from Jalaali to Gregorian format

  ## Parameters
    - arg1: Date to convert in erlang format (a tuple with three elements)
    - arg1: Date to convert in erlang format (a tuple with three elements)
    - ex_dt: Date or DateTime to convert

  ## Exmaples
  ```elixir
  iex> Jalaali.to_gregorian {1395, 9, 27}
  {2016, 12, 17}

  iex> Jalaali.to_jalaali {{2016, 12, 17}, {11, 11, 11}}
  {{1395, 9, 27}, {11, 11, 11}}

  iex> Jalaali.to_gregorian ~D[1395-09-27]
  ~D[2016-12-17]
  ```
  """
  @spec to_gregorian(tuple() | DateTime.t() | Date.t()) :: tuple() | DateTime.t() | Date.t()
  def to_gregorian({jy, jm, jd}) do
    d2g(j2d({jy, jm, jd}))
  end

  def to_gregorian({date, time}) do
    {to_gregorian(date), time}
  end

  def to_gregorian(ex_dt) do
    {gy, gm, gd} = to_gregorian({ex_dt.year, ex_dt.month, ex_dt.day})
    %{ex_dt | year: gy, month: gm, day: gd}
  end

  @doc """
  Checks whether a Jalaali date is valid or not.

  ## Parameters
    - arg1: is a tuple in shape of {jalaali_year, jalaali_month, jalaali_day}

  ## Examples
  ```elixir
  iex> Jalaali.is_valid_jalaali_date {1395, 9, 27}
  true

  iex> Jalaali.is_valid_jalaali_date {1395, 91, 27}
  false
  ```
  """
  @spec is_valid_jalaali_date(tuple()) :: boolean()
  def is_valid_jalaali_date?({jy, jm, jd}) do
    year_is_valid = jy <= 3177 && -61 <= jy
    month_is_valid = 1 <= jm && jm <= 12
    day_is_valid = 1 <= jd && jd <= Jalaali.jalaali_month_length(jy, jm)

    year_is_valid && month_is_valid && day_is_valid
  end

  @doc """
  This function is same as `is_valid_jalaali_date?` and is only here
  because i forgot to add question mark in `jalaali <= 0.1.1`

  Please use `is_valid_jalaali_date?` instead.
  """
  def is_valid_jalaali_date(jdate) do
    is_valid_jalaali_date?(jdate)
  end

  @doc """
  Checks if a Jalaali year is leap

  ## Parameters
    - jy: Jalaali Year (-61 to 3177)

  ## Examples
  ```elixir
  iex> Jalaali.is_leap_jalaali_year(1395)
  true

  iex> Jalaali.is_leap_jalaali_year(1396)
  false

  iex> Jalaali.is_leap_jalaali_year(1394)
  false
  ```
  """
  @spec is_leap_jalaali_year(integer()) :: boolean()
  def is_leap_jalaali_year(jy) do
    jal_cal(jy).leap == 0
  end

  @doc """
  Number of days in a given month in a Jalaali year.

  ## Examples
  ```elixir
  iex> Jalaali.jalaali_month_length(1395, 11)
  30

  iex> Jalaali.jalaali_month_length(1395, 6)
  31

  iex> Jalaali.jalaali_month_length(1394, 12)
  29

  iex> Jalaali.jalaali_month_length(1395, 12)
  30
  ```
  """
  @spec jalaali_month_length(integer(), integer()) :: integer()
  def jalaali_month_length(jy, jm) do
    cond do
      jm <= 6 -> 31
      jm <= 11 -> 30
      is_leap_jalaali_year(jy) -> 30
      true -> 29
    end
  end

  @doc """
  Converts jalaali date to days number
  """
  @spec jalaali_to_days(integer(), integer(), integer()) :: integer()
  def jalaali_to_days(jy, jm, jd) do
    j2d({jy, jm, jd}) - @days_offset
  end

  @doc """
  Converts days number to jalaali date
  """
  @spec days_to_jalaali(integer()) :: {integer(), integer(), integer()}
  def days_to_jalaali(days) do
    d2j(days + @days_offset)
  end

  @doc """
  This function determines if the Jalaali (persian) year is leap(366-day long) or is the common year (365-days),
  and finds the day in March (Gregorian calendar) of the first day of the Jalaali year (jy).

  ## Parameters
    - jy: Jalaali Year (-61 to 3177)
  """
  @spec jal_cal(integer()) :: map()
  def jal_cal(jy) do
    gy = jy + 621

    if jy < -61 or jy >= 3178 do
      raise "Invalid Jalaali year #{jy}"
    end

    {jump, jp, leap_j} = calc_jlimit(jy, {Enum.at(@breaks, 0), -14}, 1)

    n = jy - jp

    leap_j1 =
      if mod(jump, 33) == 4 && jump - n == 4 do
        leap_j + div(n, 33) * 8 + div(mod(n, 33) + 3, 4) + 1
      else
        leap_j + div(n, 33) * 8 + div(mod(n, 33) + 3, 4)
      end

    leap_g = div(gy, 4) - div((div(gy, 100) + 1) * 3, 4) - 150

    march = 20 + leap_j1 - leap_g

    n =
      if jump - n < 6 do
        n - jump + div(jump + 4, 33) * 33
      else
        jy - jp
      end

    leap_c = mod(mod(n + 1, 33) - 1, 4)

    leap =
      case leap_c do
        -1 -> 4
        _ -> leap_c
      end

    %{leap: leap, gy: gy, march: march}
  end

  @spec calc_jlimit(integer(), {integer(), integer()}, integer()) ::
          {integer(), integer(), integer()}
  defp calc_jlimit(jy, {jp, leap_j}, index) do
    jm = Enum.at(@breaks, index)
    jump = jm - jp

    if jy < jm do
      {jump, jp, leap_j}
    else
      calc_jlimit(jy, {jm, leap_j + div(jump, 33) * 8 + div(mod(jump, 33), 4)}, index + 1)
    end
  end

  @spec j2d({integer(), integer(), integer()}) :: integer()
  defp j2d({jy, jm, jd}) do
    r = jal_cal(jy)
    g2d({r.gy, 3, r.march}) + (jm - 1) * 31 - div(jm, 7) * (jm - 7) + jd - 1
  end

  @spec d2j(integer()) :: {integer(), integer(), integer()}
  defp d2j(jdn) do
    # calculate gregorian year (gy)
    gy = elem(d2g(jdn), 0)
    jy = gy - 621
    r = jal_cal(jy)
    jdn1f = g2d({gy, 3, r.march})
    # find number of days that passed since 1 farvardin
    k = jdn - jdn1f

    cond do
      k <= 185 && k >= 0 ->
        {jy, div(k, 31) + 1, mod(k, 31) + 1}

      k >= 0 ->
        k = k - 186

        jm = 7 + div(k, 30)
        jd = mod(k, 30) + 1
        {jy, jm, jd}

      r.leap == 1 ->
        jy = jy - 1
        k = k + 180

        jm = 7 + div(k, 30)
        jd = mod(k, 30) + 1
        {jy, jm, jd}

      true ->
        jy = jy - 1
        k = k + 179

        jm = 7 + div(k, 30)
        jd = mod(k, 30) + 1
        {jy, jm, jd}
    end
  end

  @spec g2d({integer(), integer(), integer()}) :: integer()
  defp g2d({gy, gm, gd}) do
    d =
      div((gy + div(gm - 8, 6) + 100_100) * 1461, 4) + div(153 * mod(gm + 9, 12) + 2, 5) + gd -
        34_840_408

    d - div(div(gy + 100_100 + div(gm - 8, 6), 100) * 3, 4) + 752
  end

  @spec d2g(integer()) :: {integer(), integer(), integer()}
  defp d2g(jdn) do
    j = 4 * jdn + 139_361_631 + div(div(4 * jdn + 183_187_720, 146_097) * 3, 4) * 4 - 3908
    i = div(mod(j, 1461), 4) * 5 + 308
    gd = div(mod(i, 153), 5) + 1
    gm = mod(div(i, 153), 12) + 1
    gy = div(j, 1461) - 100_100 + div(8 - gm, 6)
    {gy, gm, gd}
  end

  @spec mod(integer(), integer()) :: integer()
  defp mod(a, b) do
    a - div(a, b) * b
  end
end
