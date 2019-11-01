defmodule CLAN do
  defstruct [:id, :name, :leader, users: MapSet.new()]
end
