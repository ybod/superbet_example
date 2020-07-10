defmodule SuperbetTest do
  use ExUnit.Case
  doctest Superbet

  test "greets the world" do
    assert Superbet.hello() == :world
  end
end
