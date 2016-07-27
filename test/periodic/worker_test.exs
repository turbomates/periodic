defmodule Periodic.WorkerTest do
  use ExUnit.Case, async: true

  defmodule MyWorker do
    use Periodic.Worker,
      interval: 10,
      immediately: true

    def work(pid) do
      send(pid, :from_worker)
      {:ok, pid}
    end
  end

  defmodule MyWorker2 do
    use Periodic.Worker,
      otp_app: :periodic

    def work(pid) do
      send(pid, :from_worker2)
      {:ok, pid}
    end
  end

  test "worker execution" do
    {:ok, _} = MyWorker.start_link(self())
    assert_receive :from_worker
  end

  test "worker config from otp app configuration" do
    Application.put_env(:periodic, Periodic.WorkerTest.MyWorker2, [interval: 10000, immediately: false])
    MyWorker2.start_link(self())
    refute_receive :from_worker2
  end
end
