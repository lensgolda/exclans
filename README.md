# CLAN

## requirements

Клан - это долгосрочное объединение множества игроков. Клан имеет лидера и список участников, а также имя и клановый тег (например, [ELG] или [WTF]).
 
Сервер кланов должен выполнять следующие функции:
Создать клан (создающий игрок автоматически становится лидером).
Пригласить другого игрока в свой клан.
Принять или отклонить полученное приглашение на вступление в клан.
Исключить игрока из клана (доступно только лидеру).


Требования к реализации:
Язык программирования - Elixir.
Представляет собой либо веб-сервер, либо просто набор модулей с реализацией требуемого функционала (чистая логика без взаимодействия с внешним миром).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `exclans` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exclans, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/exclans](https://hexdocs.pm/exclans).

