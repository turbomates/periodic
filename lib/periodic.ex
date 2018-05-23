defmodule Periodic do
  def supervisor_specs_from_env(app, key) do
    import Supervisor.Spec, warn: false

    for task <- Application.get_env(app, key, []) do
      case task do
        {mod, method, state, opts} when is_atom(mod) and is_atom(method) and is_list(opts) ->
          id = Keyword.get(opts, :id, {mod, method, state, opts})
          opts = Keyword.drop(opts, [:id])
          worker(Periodic.SimpleWorker, [{mod, method, state}, opts], restart: :transient, id: id)

        {mod, state, opts} when is_atom(mod) and is_list(opts) ->
          id = Keyword.get(opts, :id, {mod, state, opts})
          opts = Keyword.drop(opts, [:id])
          worker(mod, [state, opts], restart: :transient, id: id)

        other ->
          raise "Invalid task description #{inspect(other)}"
      end
    end
  end
end
