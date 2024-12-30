defmodule FlyMachineApiTest do
  use ExUnit.Case
  doctest FlyMachineApi

  test "greets the world" do
    assert FlyMachineApi.hello() == :world
  end
end
