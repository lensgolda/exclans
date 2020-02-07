defmodule Clan do

  defstruct [:name, :leader, :tag, users: MapSet.new()]
  
  def new(name, tag) do
    %Clan{tag: tag, name: name}
  end
end
