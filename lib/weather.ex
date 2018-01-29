defmodule Weather do
  @moduledoc false

  def temperatures_of(cities) do
    coordinator_pid = spawn(Weather.Coordinator, :loop, [[], Enum.count(cities)])

    cities
    |> Enum.each(fn city ->
      worker_pid = spawn(Weather.Worker, :loop, [])
      send(worker_pid, {coordinator_pid, city})
    end)
  end
end
