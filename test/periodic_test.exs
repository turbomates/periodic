defmodule PeriodicTest do
  use ExUnit.Case, async: true

  def periodic_func1(state), do: {:ok, state}
  def periodic_func2(state), do: {:ok, state}

  setup do
    on_exit(fn ->
      Application.delete_env(:periodic, :tasks)
    end)
  end

  test "load task children from env" do
    tasks = [
      {PeriodicTest, :periodic_fun, [], []},
      {MyWorker, [], []}
    ]

    Application.put_env(:periodic, :tasks, tasks)
    assert length(Periodic.supervisor_specs_from_env(:periodic, :tasks)) == 2
  end

  test "invalid task spec" do
    tasks = [{}]

    assert_raise RuntimeError, fn ->
      Application.put_env(:periodic, :tasks, tasks)
      Periodic.supervisor_specs_from_env(:periodic, :tasks)
    end
  end

  test "children ids" do
    tasks = [
      {PeriodicTest, :periodic_func1, [], [interval: 20000]},
      {PeriodicTest, :periodic_func1, [], [id: :my_periodic_worker]},
      {PeriodicTest, :periodic_func2, [], []}
    ]

    Application.put_env(:periodic, :tasks, tasks)
    {:ok, pid} = Supervisor.start_link(Periodic.supervisor_specs_from_env(:periodic, :tasks), strategy: :one_for_one)

    assert is_pid(pid)
  end
end
