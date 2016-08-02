defmodule Periodic.SimpleWorker do
  use Periodic.Worker

  def work({m, f, state}) do
    {:ok, new_state} = apply(m, f, [state])
    {:ok, {m, f, new_state}}
  end

  def work(f) when is_function(f) do
    f.()
    {:ok, f}
  end
end
