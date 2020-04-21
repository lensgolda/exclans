defmodule Server do
  use GenServer
  alias Server.Clans, as: Clans
  alias Server.Invites, as: Invites
  alias Server.Id, as: IdGenerator

  # Specs

  @type clan_tag :: String.t
  @type clan_name :: String.t
  @type clan_create :: %{tag: clan_tag, name: clan_name}
  @type clan_leader :: number
  @type clans_users :: MapSet.t
  @type user :: %User{id: number, name: String.t, clans: MapSet.t}
  @type clan :: %Clan{tag: clan_tag, name: clan_name, leader: number, users: MapSet.t}

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

  def handle_call({:create, data, user}, _caller, {clans, invites} = state) do

    %{tag: data_tag, name: data_name} = data

    clan = Map.fetch(clans, data_tag)

    case clan do

      {:ok, %{tag: ^data_tag, name: _}} ->
        {:reply, :clan_already_exists, state}

      :error ->
        clan_new = 
          Clan.new(data_name, data_tag)
            |> Map.put(:leader, user.id)
            |> Map.update!(:users, &(MapSet.put(&1, user.id)))

        IO.puts("New clan created: #{clan_new.name}")

        Clans.put(clan_new)
        clans_state = Clans.state()

        {:reply, clan_new, {clans_state, invites}}
    end
  end

  def handle_cast({:delete, tag}, {_, invites}) do

    Clans.delete(tag)
    clans = Clans.state()

    IO.puts("Clan #{tag} successfully deleted")

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

  # Clans list
  def clans() do
    GenServer.call(:server, {:clans})
  end

  # Invites list
  def invites() do
    GenServer.call(:server, {:invites})
  end

  # Get Clan by tag
  def get(tag) do
    GenServer.call(:server, {:get, tag})
  end

  # Delete
  @spec delete(clan_tag) :: atom()
  def delete(tag) do
    GenServer.cast(:server, {:delete, tag})
  end

  # Create
  @spec create(clan_create, user) :: clan
  def create(data, user) do
    GenServer.call(:server, {:create, data, user})
  end

  # Invite
  def invite(user, clan_tag) do
    GenServer.cast(:server, {:invite, user, clan_tag})
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

end
