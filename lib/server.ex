defmodule SERVER do
  import UUID
  import CLAN

  def start_link do
    Task.start_link(fn -> loop(%{clans: %{}, invites: %{}}) end)
  end

  defp loop(state) do
    receive do
      {:list, caller} ->
        %{clans: clans} = state
        send(caller, {:ok, clans})
        loop(state)

      {:get, id, caller} ->
        send(caller, Map.get(state.clans, id))
        loop(state)

      {:create, clan_name, user, caller} ->
        %{clans: clans} = state

        clan? =
          clans
          |> Map.values()
          |> Enum.find(fn clan -> clan.name == clan_name end)

        case clan? do
          %CLAN{name: _} ->
            send(caller, {:error, :clan_name_already_exists})
            loop(state)

          nil ->
            id = UUID.uuid1()
            clan = %CLAN{id: id, name: clan_name, users: MapSet.new([user_upd]), leader: user.id}
            user_upd = %{user | clans: MapSet.put(user.clans, clan)}
            
            send(caller, {:ok, clan})
            loop(%{state | clans: Map.put(clans, id, clan)})
        end

      {:invite, user, clan_id, caller} ->
        %{clans: clans, invites: invites} = state

        invited? =
          invites
          |> Map.values()
          |> Enum.find(fn invited -> invited[:user].id == user.id end)

        clan = Map.get(clans, clan_id)

        case clan do
          %CLAN{users: users} ->
            cond do
              MapSet.member?(users, user) ->
                send(caller, {:error, :user_already_in_clan})
                loop(state)

              invited? ->
                send(caller, {:error, :user_already_invited})
                loop(state)

              true ->
                invite_id = UUID.uuid1()
                send(caller, {:ok, invite_id})
                loop(%{state | invites: Map.put(invites, invite_id, %{user: user, clan: clan})})
            end

          nil ->
            send(caller, {:error, :clan_not_found})
            loop(state)
        end

      {:accept, invite_id, caller} ->
        %{clans: clans, invites: invites} = state

        case Map.get(invites, invite_id) do
          %{user: user, clan: clan} ->
            user_upd = %{user | clans: MapSet.put(user.clans, clan)}
            # clan_upd = %{clan | users: MapSet.put(clan.users, user)}
            clans_upd = put_in(clans[clan.id].users, [user_upd | clan.users])
            invites_upd = Map.delete(invites, invite_id)
            send(caller, {:ok, user_upd})
            loop(%{state | clans: clans_upd, invites: invites_upd})

          nil ->
            send(caller, {:error, :invite_not_found})
            loop(state)
        end

      {:decline, invite_id, caller} ->
        %{invites: invites} = state
        invites_upd = Map.delete(invites, invite_id)
        send(caller, {:ok, :declined})
        loop(%{state | invites: invites_upd})

      {:kick, user, clan_id, caller} ->
        clan = state.clans[clan_id]
        case MapSet.member?(clan.users, user) do
          true ->
            state_upd = put_in(state.clans[clan_id].users, MapSet.delete(clan.users, user))
            send(caller, {:ok, :kicked})
            loop(state_upd)
          false ->
            send(caller, {:error, :user_not_found})
            loop(state)
        end
    end
  end

  # Public API

  def start do
      SERVER.start_link()
  end
end
