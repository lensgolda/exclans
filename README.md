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

## usage example

```elixir

{:ok, server} = SERVER.start()
{:ok, #PID<0.188.0>}

leader = %USER{id: 1, name: "Lens"}
%USER{clans: #MapSet<[]>, id: 1, name: "Lens"}


### Creating clan

send(server, {:create, %{name: "Panzer", tag: "[PZR]"}, leader, self()})
{:create, %{name: "Panzer", tag: "[PZR]"},
 %USER{clans: #MapSet<[]>, id: 1, name: "Lens"}, #PID<0.171.0>}

### List all clans

iex(14)> send(server, {:list, self()})                                         
{:list, #PID<0.171.0>}
iex(15)> receive do {_, data} -> data after 1000 -> "timeout" end
%{
  "13eb1a6c-fdc8-11e9-8f5c-186590cd49e7" => %CLAN{
    id: "13eb1a6c-fdc8-11e9-8f5c-186590cd49e7",
    leader: 1,
    name: "Panzer",
    tag: "[PZR]",
    users: #MapSet<[1]>
  }
}

### Trying create another one with the same name or tag

iex(16)> send(server, {:create, %{name: "Panzer", tag: "[PZR]"}, user, self()})
{:create, %{name: "Panzer", tag: "[PZR]"},
 %USER{clans: #MapSet<[]>, id: 1, name: "Lens"}, #PID<0.171.0>}

__ Getting error clan name or tag already exists __
iex(17)> receive do {:error, err} -> err after 1000 -> "timeout" end  
:clan_name_or_tag_already_exists

### Creating another user

iex(18)> user2 = %USER{id: 2, name: "John"}
%USER{clans: #MapSet<[]>, id: 2, name: "John"}

### Inviting him to existing clan

iex(19)> send(server, {:invite, user2, "13eb1a6c-fdc8-11e9-8f5c-186590cd49e7", self()})
{:invite, %USER{clans: #MapSet<[]>, id: 2, name: "John"},
 "13eb1a6c-fdc8-11e9-8f5c-186590cd49e7", #PID<0.171.0>}
iex(20)> receive do {_, data} -> data after 1000 -> "timeout" end                       
"f13b3992-fdc8-11e9-a980-186590cd49e7"

### Accepting invite

iex(21)> send(server, {:accept, "f13b3992-fdc8-11e9-a980-186590cd49e7", self()})
{:accept, "f13b3992-fdc8-11e9-a980-186590cd49e7", #PID<0.171.0>}
iex(22)> receive do {_, data} -> data after 1000 -> "timeout" end               
%USER{
  clans: #MapSet<[
    %CLAN{
      id: "13eb1a6c-fdc8-11e9-8f5c-186590cd49e7",
      leader: 1,
      name: "Panzer",
      tag: "[PZR]",
      users: #MapSet<[1]>
    }
  ]>,
  id: 2,
  name: "John"
}

### Checking user2 accepted properly to clan

iex(23)> send(server, {:list, self()})                                                                              
{:list, #PID<0.171.0>}
iex(24)> receive do {_, data} -> data after 1000 -> "timeout" end
%{
  "13eb1a6c-fdc8-11e9-8f5c-186590cd49e7" => %CLAN{
    id: "13eb1a6c-fdc8-11e9-8f5c-186590cd49e7",
    leader: 1,
    name: "Panzer",
    tag: "[PZR]",
    users: #MapSet<[1, 2]>
  }
}

### Kicking user2 from clan

iex(25)> send(server, {:kick, user2, "13eb1a6c-fdc8-11e9-8f5c-186590cd49e7", self()})
{:kick, %USER{clans: #MapSet<[]>, id: 2, name: "John"},
 "13eb1a6c-fdc8-11e9-8f5c-186590cd49e7", #PID<0.171.0>}
iex(26)> receive do {_, data} -> data after 1000 -> "timeout" end                    
:kicked
iex(27)> send(server, {:list, self()})                                               
{:list, #PID<0.171.0>}
iex(28)> receive do {_, data} -> data after 1000 -> "timeout" end
%{
  "13eb1a6c-fdc8-11e9-8f5c-186590cd49e7" => %CLAN{
    id: "13eb1a6c-fdc8-11e9-8f5c-186590cd49e7",
    leader: 1,
    name: "Panzer",
    tag: "[PZR]",
    users: #MapSet<[1]>
  }
}
```


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

