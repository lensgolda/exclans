defmodule USER do
  defstruct [:id, :name, clans: MapSet.new()]
end
