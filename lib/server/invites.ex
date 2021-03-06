defmodule Server.Invites do
  use Agent

  def start_link() do
    Agent.start_link(fn -> %{} end, name: :invites)
  end

  def get(id) do
    Agent.get(:invites, fn invites ->
      Map.get(invites, id)
    end)
  end

  def put(id, invite) do
    Agent.update(:invites, fn invites ->
      Map.update(invites, id, MapSet.new([invite]), &MapSet.put(&1, invite))
    end)
  end

  def delete(id, clan_id) do
    Agent.update(:invites, fn invites ->
      Map.update(invites, id, MapSet.new(), &MapSet.delete(&1, clan_id))
    end)
  end

  def state() do
    Agent.get(:invites, fn invites -> invites end)
  end
end
