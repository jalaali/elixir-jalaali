# Elixir Jalaali calendar
[![Build Status](https://travis-ci.org/jalaali/elixir-jalaali.svg?branch=master)](https://travis-ci.org/jalaali/elixir-jalaali) [![Hex.pm](https://img.shields.io/badge/hex-0.2.1-blue.svg)](https://hex.pm/packages/jalaali) [![GitHub license](https://img.shields.io/badge/license-MIT-green.svg)](https://raw.githubusercontent.com/jalaali/elixir-jalaali/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/jalaali/elixir-jalaali.svg)](https://github.com/jalaali/elixir-jalaali/issues)

Elixir implementation of [jalaali.js](https://github.com/jalaali/jalaali-js) which contains a Calendar implementation for jalaali and some functions for converting Jalaali and Gregorian calendar systems to each other.

## Installation

You can install `jalaali` by Addding it to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:jalaali, "~> 0.3"}]
end
```

## Usage

After installing jalaali package. you can create Dates/DateTimes in jalaali or convert
Dates/DateTimes form other calendars back an forth.

**This feature is intruduced in Elixir 1.5 so in any versions below 1.5 the `Date`
and `DateTime` modules lack functions for converting calendars. However you can
just copy those modules but its just better to migrate to 1.5 or above**

### How to use

  - Creating new Date
```elixir
  Date.new(1396, 6, 30, Jalaali.Calendar)
  {:ok, %Date{calendar: Jalaali.Calendar, day: 30, month: 6, year: 1396}}
```

  - Converting a DateTime to Jalaali
```elixir
  datetime_in_any_calendar = DateTime.utc_now(Calendar.ISO)
  {:ok, jalaali_datetime} = DateTime.convert(datetime_in_any_calendar, Jalaali.Calendar)
```

  - Converting a DateTime from Jalaali
```elixir
  jalaali_datetime = DateTime.utc_now(Jalaali.Calendar)
  {:ok, iso_datetime} = DateTime.convert(jalaali_datetime, Calendar.ISO)
```

  - Converting a Date to Jalaali
```elixir
  date_in_any_calendar = Date.new(2017, 1, 1, Calendar.ISO)
  {:ok, jalaali_date} = Date.convert(date_in_any_calendar, Jalaali.Calendar)
```

  - Converting a Date from Jalaali
```elixir
  {:ok, jalaali_date} = Date.new(1396, 6, 30, Jalaali.Calendar)
  {:ok, iso_date} = Date.convert(jalaali_date, Calendar.ISO)
```

  Thats super easy. :)

## License

This project is license under MIT.

For more information please check [LICENSE](https://github.com/jalaali/elixir-jalaali/blob/master/LICENSE)
