defmodule Server.Clans do
    use Agent

    def start_link() do
        Agent.start_link(fn -> %{} end, name: :clans)
    end

    def get(id) do
        Agent.get(:clans, fn clans -> Map.get(clans, id) end)
    end

    def put(%{id: id} = clan) do
        Agent.update(:clans, fn clans -> 
            Map.put(clans, id, clan) 
        end)
    end

    def delete(id) do
        Agent.get_and_update(:clans, fn clans -> 
            Map.pop(clans, id) 
        end)
    end

    def state() do
        Agent.get(:clans, fn clans -> clans end)
    end
end