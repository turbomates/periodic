defmodule PeriodicTest do
  use ExUnit.Case, async: true

  test "load task children from env" do
    tasks = [
      {PeriodicTest, :periodic_fun, [], []},
      {MyWorker, [], []}
    ]

    Application.put_env(:periodic, :tasks, tasks)
    assert length(Periodic.task_children) == 2
  end

  test "invalid task spec" do
    tasks = [{}]

    assert_raise RuntimeError, fn ->
      Application.put_env(:periodic, :tasks, tasks)
      Periodic.task_children
    end
  end
end
