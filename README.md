[![Build Status](https://travis-ci.org/swelham/ivar_httpoison.svg?branch=master)](https://travis-ci.org/swelham/ivar_httpoison) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/swelham/ivar_httpoison.svg)](https://beta.hexfaktor.org/github/swelham/ivar_httpoison) [![Hex Version](https://img.shields.io/hexpm/v/ivar_httpoison.svg)](https://hex.pm/packages/ivar_httpoison)

# Ivar HTTPoison

An HTTPoison adapter for the Ivar HTTP client

## Usage

Add `ivar_httpoison` to your list of dependencies in `mix.exs`

```elixir
def deps do
  [
    {:ivar_httpoison, "~> 0.1.0"}
  ]
end
```

And then configure Ivar to use the adapter

```elixir
config :ivar,
  adapter: Ivar.HTTPoison
```

## HTTPoison Config

You can configure any of the HTTPoison options via the `http` config key and these will be passed onto HTTPoison

```elixir
config :ivar,
  adapter: Ivar.HTTPoison,
  http: [
    timeout : 5_000
  ]
```
