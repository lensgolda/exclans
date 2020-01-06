defmodule Server.Id do
    use Agent

    def start_link() do
        Agent.start_link(fn -> 1 end, name: :ids)
    end

    def generate() do
        Agent.get_and_update(:ids, fn id -> {id, id + 1} end)
    end
end