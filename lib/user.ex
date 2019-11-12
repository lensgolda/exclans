defmodule User do
  defstruct [:id, :name, clans: MapSet.new()]
end
