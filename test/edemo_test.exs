defmodule EdemoTest do
  use ExUnit.Case
  doctest Edemo

  test "greets the world" do
    assert Edemo.hello() == :world
  end
end
