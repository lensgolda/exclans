defmodule Server.Clans do
    use Agent

    def start_link() do
        Agent.start_link(fn -> %{} end, name: :clans)
    end

    # implemented
    def get(tag) do
        Agent.get(:clans, fn clans -> 
            Map.get(clans, tag) 
        end)
    end

    # implemented
    def put(%Clan{tag: tag} = clan) do
        Agent.update(:clans, fn clans -> 
            Map.put(clans, tag, clan) 
        end)
    end

    # implemented
    def delete(tag) do
        Agent.get_and_update(:clans, fn clans -> 
            Map.pop(clans, tag)
        end)
    end

    #implemented
    def state() do
        Agent.get(:clans, fn clans -> clans end)
    end
end