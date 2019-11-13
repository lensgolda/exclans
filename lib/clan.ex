defmodule Clan do

  defstruct [:id, :name, :leader, :tag, users: MapSet.new()]

  def new(name, tag) do
    id = UUID.uuid1()
    %Clan{id: id, name: name, tag: tag}
  end
end
