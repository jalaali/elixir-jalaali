# Elixir Jalaali calendar
[![Build Status](https://travis-ci.org/jalaali/elixir-jalaali.svg?branch=master)](https://travis-ci.org/jalaali/elixir-jalaali) [![Hex.pm](https://img.shields.io/badge/hex-0.1.1-yellow.svg)](https://hex.pm/packages/jalaali) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/jalaali/elixir-jalaali/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/jalaali/elixir-jalaali.svg)](https://github.com/jalaali/elixir-jalaali/issues) 

Elixir implementation of [jalaali.js](https://github.com/jalaali/jalaali-js) which contains functions for converting Jalaali and Gregorian calendar systems to each other.

## Installation

You can install `jalaali` by:

  1. Addding `jalaali` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:jalaali, "~> 0.1.0"}]
    end
    ```

  2. Ensuring `jalaali` is started before your application:

    ```elixir
    def application do
      [applications: [:jalaali]]
    end
    ```

## Usage

After installing jalaali package. you can use it for:

  - Converting Gregorian dates to Jalaali:

  ```elixir
    jal_date = Jalaali.to_jalaali(~D[2015-02-29])
  ```

  - Converting Jalaali dates to Gregorian:

  ```elixir
    gre_date = Jalaali.to_gregorian(~D[1395-03-15])
  ```

  - Checking for Jalaali leap years:

  ```elixir
    Jalaali.is_leap_jalaali_year(1395)
    true
  ```

  - Get a Jalaali month lenght

  ```elixir
    Jalaali.jalaali_month_length(1395, 12)
    30
  ```
