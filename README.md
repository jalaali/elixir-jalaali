# Elixir Jalaali calendar

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
