defmodule PeriodicTest do
  use ExUnit.Case, async: true

  def periodic_func(pid) do
    send(pid, :from_periodic)
    {:ok, [pid]}
  end

  test "periodic function call" do
    parent = self()
    Periodic.start_link(fn -> send(parent, :from_periodic) end)
    assert_receive :from_periodic
  end

  test "periodic function with args call" do
    parent = self()
    Periodic.start_link({fn m -> send(parent, m); {:ok, m}; end, [:from_periodic]})
    assert_receive :from_periodic
  end

  test "periodic module function call with args" do
    parent = self()
    Periodic.start_link({PeriodicTest, :periodic_func, [parent]})
    assert_receive :from_periodic
  end
end
