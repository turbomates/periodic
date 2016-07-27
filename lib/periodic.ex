defmodule Periodic do
  use Periodic.Worker

  def work({m, f, a}) do
    {:ok, new_args} = apply(m, f, a)
    {:ok, {m, f, new_args}}
  end

  def work({f, a}) do
    {:ok, new_args} = apply(f, a)
    {:ok, {f, new_args}}
  end

  def work(f) when is_function(f) do
    f.()
    {:ok, f}
  end
end
