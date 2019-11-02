defmodule CLAN do
  defstruct [:id, :name, :leader, :tag, users: MapSet.new()]
end
