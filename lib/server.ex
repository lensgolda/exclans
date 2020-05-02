defmodule Server do
  use GenServer, restart: :transient
  alias Server.Clans, as: Clans
  alias Server.Invites, as: Invites
  alias Server.Id, as: IdGenerator

  # Specs

  @type clan_tag :: String.t()
  @type clan_name :: String.t()
  @type clan_create :: %{tag: clan_tag, name: clan_name}
  @type clan_leader :: number
  @type clans_users :: MapSet.t()
  @type user :: %User{id: number, name: String.t(), clans: MapSet.t()}
  @type clan :: %Clan{tag: clan_tag, name: clan_name, leader: number, users: MapSet.t()}

  # Server API

  def init(:ok) do
    {:ok, _} = Clans.start_link()
    {:ok, _} = Invites.start_link()
    {:ok, _} = IdGenerator.start_link()

    # Process.monitor(clans_server)
    # Process.monitor(invites_server)
    # Process.monitor(id_generator)

    {:ok, {Clans.state(), Invites.state()}}
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

  def handle_call({:create, data, user}, _caller, {_, invites} = state) do
    %{tag: data_tag, name: data_name} = data

    clan = Clans.get(data_tag)

    case clan do
      %{tag: ^data_tag} ->
        {:reply, :clan_already_exists, state}

      nil ->
        clan_new =
          Clan.new(data_name, data_tag)
          |> Map.put(:leader, user.id)
          |> Map.update(:users, MapSet.new(), &MapSet.put(&1, user.id))

        Clans.put(clan_new)
        IO.puts("New clan created: #{clan_new.name}")

        user_upd =
          Map.update(user, :clans, MapSet.new([clan_new.tag]), &MapSet.put(&1, clan_new.tag))

        {:reply, {clan_new, user_upd}, {Clans.state(), invites}}
    end
  end

  def handle_cast({:delete, tag}, {_, invites} = state) do
    case Clans.delete(tag) do
      nil ->
        IO.puts("Clan with tag #{tag} not exists")
        {:noreply, state}

      _ ->
        IO.puts("Clan #{tag} successfully deleted")
        {:noreply, {Clans.state(), invites}}
    end
  end

  def handle_call({:invite, leader_id, user_id, clan_tag}, _caller, {clans, _} = state) do
    invite = Invites.get(user_id)

    invite = if is_nil(invite), do: MapSet.new(), else: invite

    case Clans.get(clan_tag) do
      %{leader: clan_leader_id} when clan_leader_id !== leader_id ->
        IO.puts("Only clan leader can invite")
        {:reply, :only_leader_can_invite, state}

      %{tag: tag, users: clan_users} ->
        cond do
          MapSet.member?(invite, clan_tag) ->
            IO.puts("Already invited")
            {:reply, :already_invited, state}

          MapSet.member?(clan_users, user_id) ->
            IO.puts("User already in clan")
            {:reply, :already_in_clan, state}

          true ->
            Invites.put(user_id, tag)
            {:reply, %{invite_id: user_id, clans: Invites.get(user_id)}, {clans, Invites.state()}}
        end

      nil ->
        IO.puts("Clan not found")
        {:reply, :clan_not_found, state}
    end
  end

  def handle_call({:accept, user, clan_tag}, _caller, state) do
    invite = Invites.get(user.id)

    case invite do
      nil ->
        IO.puts("Invites not found")
        {:reply, :no_invites_found, state}

      %MapSet{} ->
        invite_clan =
          invite
          |> MapSet.intersection(MapSet.new([clan_tag]))
          |> MapSet.to_list()
          |> List.first()

        cond do
          MapSet.member?(user.clans, clan_tag) ->
            IO.puts("User already in clan")
            {:reply, :already_in_clan, state}

          invite_clan !== clan_tag ->
            {:reply, :no_invites_found_for_clan, state}

          true ->
            Invites.delete(user.id, invite_clan)
            clan = Clans.get(invite_clan)

            case clan do
              nil ->
                IO.puts("Clan not found")
                {:reply, :clan_not_found, state}

              %Clan{} ->
                clan_upd = Map.update(clan, :users, MapSet.new(), &MapSet.put(&1, user.id))
                Clans.put(clan_upd)

              _ ->
                IO.puts("Unknown invite accept error")
                {:reply, :unknown_accept_error, state}
            end

            user_upd = Map.update(user, :clans, MapSet.new(), &MapSet.put(&1, clan_tag))

            {:reply, user_upd, {Clans.state(), Invites.state()}}
        end

      _ ->
        IO.puts("Unknown invite accept error")
        {:reply, :unknown_accept_error, state}
    end
  end

  def handle_cast({:decline, user, clan_tag}, {clans, _} = state) do
    invite = Invites.get(user.id)

    case invite do
      nil ->
        IO.puts("Invite not found")
        {:noreply, state}

      %MapSet{} ->
        Invites.delete(user.id, clan_tag)
        {:noreply, {clans, Invites.state()}}

      _ ->
        IO.puts("Unknown invite decline error")
        {:noreply, state}
    end
  end

  # TODO: only clan leader can kick users from clan
  def handle_call({:kick, user, clan_tag}, _caller, {_, invites} = state) do
    clan = Clans.get(clan_tag)

    case clan do
      nil ->
        IO.puts("Clan not found")
        {:reply, :clan_not_found, state}

      %Clan{users: clan_users, tag: clan_tag, leader: leader_id} ->
        cond do
          leader_id == user.id ->
            IO.puts("Clan leader can't be kicked")
            {:reply, :leader_cant_be_kicked, state}

          not MapSet.member?(clan_users, user.id) ->
            IO.puts("User is not member of clan #{clan_tag}")
            {:reply, :user_is_not_clan_member, state}

          not MapSet.member?(user.clans, clan_tag) ->
            IO.puts("User is not in clan #{clan_tag}")
            {:reply, :user_is_not_clan_member, state}

          true ->
            clan_upd = Map.update(clan, :users, MapSet.new(), &MapSet.delete(&1, user.id))
            Clans.put(clan_upd)
            user_upd = Map.update(user, :clans, MapSet.new(), &MapSet.delete(&1, clan_tag))
            {:reply, user_upd, {Clans.state(), invites}}
        end

      _ ->
        IO.puts("Unknown invite kick error")
        {:reply, :unknown_kick_error, state}
    end
  end

  # Client API

  # for testing
  # def init() do
  #   {_, server} = Server.start_link()
  #   user1 = User.new("User1")
  #   user2 = User.new("User2")
  #   user3 = User.new("User3")
  #   {clan1, user1} = Server.create(%{tag: "clan1", name: "Clan1"}, user1)
  #   {clan2, user2} = Server.create(%{tag: "clan2", name: "Clan2"}, user2)
  #   {server, user1, user2, user3, clan1, clan2}
  # end

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
  @spec invite(user, user, clan) :: atom()
  def invite(leader, user, clan) do
    GenServer.call(:server, {:invite, leader.id, user.id, clan.tag})
  end

  # Accept
  def accept(user, clan_tag) do
    GenServer.call(:server, {:accept, user, clan_tag})
  end

  # Decline
  def decline(user, clan_tag) do
    GenServer.cast(:server, {:decline, user, clan_tag})
  end

  # Kick
  def kick(user, clan_tag) do
    GenServer.call(:server, {:kick, user, clan_tag})
  end
end
