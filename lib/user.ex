defmodule User do
  alias Server.Id, as: ID
  defstruct [:id, :name, clans: MapSet.new()]

  def new(name) do
    id = ID.generate()
    %User{id: id, name: name}
  end
end
