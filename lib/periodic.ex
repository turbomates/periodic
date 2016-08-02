defmodule Periodic do
  use Application

  def start(_, _) do
    Supervisor.start_link(task_children, strategy: :one_for_one, name: Periodic.Supervisor)
  end

  def task_children do
    import Supervisor.Spec, warn: false

    for task <- Application.get_env(:periodic, :tasks, []) do
      case task do
        {mod, method, state, opts} when is_atom(mod) and is_atom(method) and is_list(opts) ->
          worker(Periodic.SimpleWorker, [{mod, method, state}, opts], restart: :transient)
        {mod, state, opts} when is_atom(mod) and is_list(opts) ->
          worker(mod, [state, opts], restart: :transient)
        other ->
          raise "Invalid task description #{inspect(other)}"
      end
    end
  end
end
