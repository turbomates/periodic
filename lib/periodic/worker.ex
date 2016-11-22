defmodule Periodic.Worker do
  defmacro __using__(opts \\ []) do
    default_interval = Keyword.get(opts, :interval, 5000)
    default_immediately = Keyword.get(opts, :immediately, true)
    otp_app = Keyword.get(opts, :otp_app)

    quote do
      use GenServer
      require Logger

      @default_interval unquote(default_interval)
      @default_immediately unquote(default_immediately)

      def start_link(), do: start_link([])
      def start_link(state), do: start_link(state, [])
      def start_link(state, opts) do
        interval = config_option(unquote(otp_app), opts, :interval, @default_interval)
        immediately = config_option(unquote(otp_app), opts, :immediately, @default_immediately)
        opts = Keyword.drop(opts, [:interval, :immediately])
        GenServer.start_link(__MODULE__, {interval, immediately, state}, opts)
      end

      def setup(state), do: state

      def work(state) do
        Logger.warn("You must implement work method body for #{inspect(__MODULE__)}")
        {:ok, state}
      end

      def init({interval, immediately, state}) do
        worker = self()
        spawn_link(fn -> loop(worker, interval, immediately) end)
        {:ok, {interval, __MODULE__.setup(state)}}
      end

      def handle_call(:__periodic_work__, _, {interval, state}) do
        case work(state) do
          {:ok, state} ->
            {:reply, {:ok, interval}, {interval, state}}
          {:ok, state, new_interval} ->
            {:reply, {:ok, new_interval}, {new_interval, state}}
          {:stop, reason, state} ->
            {:stop, reason, :ok, state}
          error -> error
        end
      end

      defp loop(worker, interval, immediately) do
        unless immediately, do: :timer.sleep(interval)
        {:ok, new_interval} = GenServer.call(worker, :__periodic_work__, :infinity)
        :timer.sleep(new_interval)
        loop(worker, new_interval, true)
      end

      defp config_option(otp_app, opts, name, default) do
        if opts[name] do
          opts[name]
        else
          if otp_app do
            Application.get_env(otp_app, __MODULE__, []) |> Keyword.get(name, default)
          else
            default
          end
        end
      end

      defoverridable [work: 1, setup: 1]
    end
  end
end
