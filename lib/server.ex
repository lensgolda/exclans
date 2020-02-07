defmodule Server do
  use GenServer
  alias Server.Clans, as: Clans
  alias Server.Invites, as: Invites
  alias Server.Id, as: IdGenerator

  # Server API

  def init(:ok) do
    {:ok, clans_server} = Clans.start_link()
    {:ok, invites_server} = Invites.start_link()
    {:ok, id_generator} = IdGenerator.start_link()
    Process.monitor(clans_server)
    Process.monitor(invites_server)
    clans = Clans.state()
    invites = Invites.state()
    {:ok, {clans, invites}}
  end

  def handle_call({:clans}, _caller, {clans, _} = state) do
    {:reply, clans, state}
  end

  def handle_call({:invites}, _caller, {_, invites} = state) do
    {:reply, invites, state}
  end

  def handle_call({:get, tag}, _caller, {clans, _} = state) do
    {:reply, Map.fetch(clans, tag), state}
  end

  def handle_call({:create, data, user}, {clans, invites} = state) do

    %{tag: data_tag, name: data_name} = data

    clan = Map.fetch(clans, data_tag)

    case clan do
      {:ok, %{tag: ^data_tag, name: _}} ->
        {:reply, :clan_already_exists, state}
      :error ->
        clan_new = Clan.new(data.name, data.tag)
        clan_new
          |> clan_new.put(:leader, user.id)
          |> clan_new.put(:users, MapSet.put(clan_new.users, user.id))
        # clan_new = %{clan_new | leader: user.id}
        # clan_new = %{clan_new | users: MapSet.put(clan_new.users, user.id)}
        # Clans.put(clan_new)
        # clans_state = Clans.state()
        
        clans = Clans.put(clan_new)

        {:noreply, {clans, invites}}
        
    end
  end

  def handle_cast({:delete, tag}, {_, invites}) do
    # Clans.delete(tag)
    # clans_state = Clans.state()
    
    clans = Clans.delete(tag)

    {:noreply, {clans, invites}}
  end

  def handle_call({:invite, user, clan_tag}, _caller, {clans, invites}) do
    # TODO
    IO.puts("Not implemented yet")
  end

  def handle_cast({:accept, invite_id}, {_, invites}) do
    # TODO
    IO.puts("Not implemented yet")
  end

  def handle_cast({:decline, invite_id}, {_, invites}) do
    # TODO
    IO.puts("Not implemented yet")
  end

  def handle_cast({:kick, user, clan_id}) do
    # TODO
    IO.puts("Not implemented yet")
  end
  
  # Client API

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: :server)
  end

  def clans() do
    GenServer.call(:server, {:clans})
  end

  def invites() do
    GenServer.call(:server, {:invites})
  end

  def get(id) do
    GenServer.call(:server, {:get, id})
  end

  def delete(id) do
    GenServer.cast(:server, {:delete, id})
  end

  # Create
  def create(data, user) do
    GenServer.call(:server, {:create, data, user})
  end

  # Invite
  def invite(user, clan_id) do
    GenServer.cast(:server, {:invite, user, clan_id})
  end

  # Accept
  def accept(invite_id) do
    GenServer.cast(:server, {:accept, invite_id})
  end

  # Decline
  def decline(invite_id) do
    GenServer.cast(:server, {:decline, invite_id})
  end

  # Kick
  def kick(user, clan_id) do
    GenServer.cast(:server, {:kick, user, clan_id})
  end

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
