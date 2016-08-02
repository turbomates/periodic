defmodule Periodic.SimpleWorkerTest do
  use ExUnit.Case

  def periodic_func(pid) do
    send(pid, :hello)
    {:ok, pid}
  end

  test "execute simple worker" do
    {:ok, _} = Periodic.SimpleWorker.start_link({Periodic.SimpleWorkerTest, :periodic_func, self()}, [])

    assert_receive :hello
  end
end
