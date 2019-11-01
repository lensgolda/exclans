defmodule CLANTest do
  use ExUnit.Case
  doctest CLAN

  test "greets the world" do
    assert CLAN.hello() == :world
  end
end
