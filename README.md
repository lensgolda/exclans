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
iex(16)> {_, server} = Server.start()                                                                                                                                              
{:ok, #PID<0.381.0>}                                                                                                                                                               
iex(17)> user1 = User.new("User1")                                                                                                                                                 
%User{clans: #MapSet<[]>, id: 1, name: "User1"}                                                                                                                                    
iex(18)> user2 = User.new("User2")
%User{clans: #MapSet<[]>, id: 2, name: "User2"}
iex(19)> user3 = User.new("User3")
%User{clans: #MapSet<[]>, id: 3, name: "User3"}
iex(20)> {clan1, user1} = Server.create(%{tag: "clan1", name: "Clan1"}, user1)
New clan created: Clan1
{%Clan{leader: 1, name: "Clan1", tag: "clan1", users: #MapSet<[1]>},
 %User{clans: #MapSet<["clan1"]>, id: 1, name: "User1"}}
iex(21)> {clan2, user2} = Server.create(%{tag: "clan2", name: "Clan2"}, user2)
New clan created: Clan2
{%Clan{leader: 2, name: "Clan2", tag: "clan2", users: #MapSet<[2]>},
 %User{clans: #MapSet<["clan2"]>, id: 2, name: "User2"}}
iex(22)> Server.clans
%{
  "clan1" => %Clan{leader: 1, name: "Clan1", tag: "clan1", users: #MapSet<[1]>},
  "clan2" => %Clan{leader: 2, name: "Clan2", tag: "clan2", users: #MapSet<[2]>}
}
iex(23)> Server.invites
%{}
iex(24)> Server.invite(user1, user3, clan2)
Only clan leader can invite
:only_leader_can_invite
iex(25)> Server.invite(user1, user3, clan1)
%{clans: #MapSet<["clan1"]>, invite_id: 3}
iex(26)> Server.invite(user2, user3, clan2)
%{clans: #MapSet<["clan1", "clan2"]>, invite_id: 3}
iex(27)> Server.decline(user3, clan2.tag)
:ok
iex(28)> Server.invites
%{3 => #MapSet<["clan1"]>}
iex(29)> Server.accept(user3,clan1.tag)
%User{clans: #MapSet<["clan1"]>, id: 3, name: "User3"}
iex(30)> Server.clans
%{
  "clan1" => %Clan{
    leader: 1,
    name: "Clan1",
    tag: "clan1",
    users: #MapSet<[1, 3]>
  },
  "clan2" => %Clan{leader: 2, name: "Clan2", tag: "clan2", users: #MapSet<[2]>}
}
iex(31)> Server.invites
%{3 => #MapSet<[]>}
iex(32)>
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

