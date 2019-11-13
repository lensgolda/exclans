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

    def put(id, clan) do
        Agent.update(:invites, fn invites -> 
            Map.put(invites, id, clan) 
        end)
    end

    def delete(id) do
        Agent.get_and_update(:invites, fn invites -> 
            Map.pop(invites, id) 
        end)
    end

    def state() do
        Agent.get(:invites, fn invites -> invites end)
    end
end