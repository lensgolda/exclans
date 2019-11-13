defmodule User do
  defstruct [:id, :name, clans: MapSet.new()]

  def new(name) do
    id = UUID.uuid1()
    %User{id: id, name: name}
  end
end
