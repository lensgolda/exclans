defmodule Server do
  use GenServer

  # GenServer callbacks

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:all}, caller, clans}) do
    {:ok, clans}
  end

  @impl true
  def handle_call({:get, id}, caller, clans) do
    {:ok, Map.fetch(clans, id), clans}
  end
  
  # Client API

  import UUID
  import Clan

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def clans(server) do
    GenServer.call(server, {:all})
  end

  def get(server, id) do
    GenServer.call(server, {:get, id})
  end

  # Create

  # Invite

  # Accept

  # Decline

  # Kick

  # defp loop(state) do
  #   receive do
  #     # List all clans
  #     {:list, caller} ->
  #       send(caller, {:ok, state.clans})
  #       loop(state)
      
  #     # Get clan by ID
  #     {:get, id, caller} ->
  #       case Map.get(state.clans, id) do
  #         %Clan{id: id} ->
  #           send(caller, {:ok, state.clans[id]})
  #         nil ->
  #           send(caller, {:error, :clan_not_found})
  #           loop(state)
  #       end
      
  #     # Creates clan, where clan_data is 
  #     # a map with :name and :tag keys required
  #     {:create, clan_data, user, caller} ->
  #       # %{clans: clans} = state
  #       %{name: name, tag: tag} = clan_data

  #       clan? =
  #         state.clans
  #         |> Map.values()
  #         |> Enum.find(fn clan -> clan.tag == tag || clan.name == name end)

  #       case clan? do
  #         %Clan{} ->
  #           send(caller, {:error, :clan_name_or_tag_already_exists})
  #           loop(state)

  #         nil ->
  #           id = UUID.uuid1()
  #           clan = %Clan{id: id, name: name, tag: tag, users: MapSet.new([user.id]), leader: user.id}
  #           user_upd = %{user | clans: MapSet.put(user.clans, clan.id)}
            
  #           send(caller, {:ok, clan, user_upd})
  #           loop(%{state | clans: Map.put(state.clans, id, clan)})
  #       end

  #     # Invites user to clan
  #     {:invite, user, clan_id, caller} ->
  #       %{clans: clans, invites: invites} = state

  #       invited? =
  #         invites
  #         |> Map.values()
  #         # or simply find by invite_id
  #         |> Enum.find(fn invite -> invite.user.id == user.id end)

  #       clan = Map.get(clans, clan_id)

  #       case clan do
  #         %Clan{users: users} ->
  #           cond do
  #             MapSet.member?(users, user) ->
  #               send(caller, {:error, :user_already_in_clan})
  #               loop(state)

  #             invited? ->
  #               send(caller, {:error, :user_already_invited})
  #               loop(state)

  #             true ->
  #               invite_id = UUID.uuid1()
  #               send(caller, {:ok, invite_id})
  #               loop(%{state | invites: Map.put(invites, invite_id, %{user: user, clan: clan})})
  #           end

  #         nil ->
  #           send(caller, {:error, :clan_not_found})
  #           loop(state)
  #       end

  #     # Accepts invite
  #     {:accept, invite_id, caller} ->
  #       %{clans: clans, invites: invites} = state

  #       case Map.get(invites, invite_id) do
  #         %{user: user, clan: clan} ->
  #           # possibly get_and_update_in?
  #           user_upd = %{user | clans: MapSet.put(user.clans, clan.id)}
  #           clans_upd = put_in(clans[clan.id].users, MapSet.put(clans[clan.id].users, user.id))
  #           invites_upd = Map.delete(invites, invite_id)
  #           send(caller, {:ok, user_upd})
  #           loop(%{state | clans: clans_upd, invites: invites_upd})

  #         nil ->
  #           send(caller, {:error, :invite_not_found})
  #           loop(state)
  #       end
      
  #     # Decline invite
  #     {:decline, invite_id, caller} ->
  #       %{invites: invites} = state
  #       invites_upd = Map.delete(invites, invite_id)
  #       send(caller, {:ok, :declined})
  #       loop(%{state | invites: invites_upd})

  #     # Kicks user from clan
  #     {:kick, user, clan_id, caller} ->
  #       clan = state.clans[clan_id]
  #       case MapSet.member?(clan.users, user.id) do
  #         true ->
  #           state_upd = put_in(state.clans[clan_id].users, MapSet.delete(clan.users, user.id))
  #           send(caller, {:ok, :kicked})
  #           loop(state_upd)
  #         false ->
  #           send(caller, {:error, :user_not_found})
  #           loop(state)
  #       end
  #   end
  # end
end
